import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/navigation_service.dart';
import '../data/models/pdf_models.dart';
import '../data/repositories/pdf_repository.dart';
import '../service/pdf_file_service.dart';

/// Controller for the PDF tools dashboard.
///
/// Manages recent files, history, search, filters, and navigation.
class PdfToolsController extends GetxController {
  /// PDF file service.
  final PdfFileService _fileService = Get.find<PdfFileService>();

  /// PDF repository.
  final PdfRepository _repository = Get.find<PdfRepository>();

  /// Navigation service.
  final NavigationService _navigationService = Get.find<NavigationService>();

  /// Recent PDF files.
  final RxList<PdfFileItem> recentFiles = RxList<PdfFileItem>(<PdfFileItem>[]);

  /// PDF history entries.
  final RxList<PdfHistoryEntry> historyEntries =
      RxList<PdfHistoryEntry>(<PdfHistoryEntry>[]);

  /// Search query.
  final RxString searchQuery = RxString('');

  /// Selected filter.
  final Rx<PdfFilter> filter = Rx<PdfFilter>(PdfFilter.all);

  /// Sort order.
  final Rx<PdfSort> sortOrder = Rx<PdfSort>(PdfSort.newest);

  /// Whether files are loading.
  final RxBool isLoading = RxBool(false);

  /// Filtered recent files based on search and filter.
  List<PdfFileItem> get filteredRecentFiles {
    final List<PdfFileItem> files = List<PdfFileItem>.of(recentFiles);
    final String query = searchQuery.value.trim().toLowerCase();

    if (query.isNotEmpty) {
      files.removeWhere(
        (PdfFileItem f) => !f.fileName.toLowerCase().contains(query),
      );
    }

    switch (filter.value) {
      case PdfFilter.all:
        break;
      case PdfFilter.favorites:
        files.removeWhere((PdfFileItem f) => !f.isFavorite);
        break;
      case PdfFilter.created:
        files.removeWhere(
          (PdfFileItem f) => f.source != 'created',
        );
        break;
      case PdfFilter.imported:
        files.removeWhere(
          (PdfFileItem f) => f.source != 'imported',
        );
        break;
    }

    switch (sortOrder.value) {
      case PdfSort.newest:
        files.sort((PdfFileItem a, PdfFileItem b) =>
            b.createdAt.compareTo(a.createdAt),);
        break;
      case PdfSort.oldest:
        files.sort((PdfFileItem a, PdfFileItem b) =>
            a.createdAt.compareTo(b.createdAt),);
        break;
      case PdfSort.nameAsc:
        files.sort((PdfFileItem a, PdfFileItem b) =>
            a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()),);
        break;
      case PdfSort.nameDesc:
        files.sort((PdfFileItem a, PdfFileItem b) =>
            b.fileName.toLowerCase().compareTo(a.fileName.toLowerCase()),);
        break;
      case PdfSort.largest:
        files.sort((PdfFileItem a, PdfFileItem b) =>
            (b.fileSize ?? 0).compareTo(a.fileSize ?? 0),);
        break;
      case PdfSort.smallest:
        files.sort((PdfFileItem a, PdfFileItem b) =>
            (a.fileSize ?? 0).compareTo(b.fileSize ?? 0),);
        break;
    }

    return files;
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// Initializes the controller.
  Future<void> _initialize() async {
    isLoading.value = true;
    recentFiles.value = await _repository.getRecentFiles();
    historyEntries.value = await _repository.getHistoryEntries();
    isLoading.value = false;
  }

  /// Imports a PDF file.
  Future<void> importPdf() async {
    final PdfFileItem? file = await _fileService.pickPdf();
    if (file != null) {
      await _repository.saveRecentFile(file);
      recentFiles.insert(0, file);
    }
  }

  /// Navigates to a PDF tool route.
  void navigateToTool(PdfOperation operation) {
    switch (operation) {
      case PdfOperation.textToPdf:
        _navigationService.to(AppRoutes.textToPdf);
        break;
      case PdfOperation.pdfToText:
        _navigationService.to(AppRoutes.pdfToText);
        break;
      case PdfOperation.merge:
        _navigationService.to(AppRoutes.mergePdf);
        break;
      case PdfOperation.split:
        _navigationService.to(AppRoutes.splitPdf);
        break;
      case PdfOperation.compress:
        _navigationService.to(AppRoutes.compressPdf);
        break;
    }
  }

  /// Toggles favorite status for a recent file.
  Future<void> toggleFavorite(PdfFileItem file) async {
    final PdfFileItem updated = file.copyWith(isFavorite: !file.isFavorite);
    await _repository.saveRecentFile(updated);
    final int index = recentFiles.indexWhere(
      (PdfFileItem f) => f.id == file.id,
    );
    if (index >= 0) {
      recentFiles[index] = updated;
    }
  }

  /// Deletes a recent file.
  Future<void> deleteRecentFile(String id) async {
    await _repository.deleteRecentFile(id);
    recentFiles.removeWhere((PdfFileItem f) => f.id == id);
  }

  /// Updates the search query.
  // ignore: use_setters_to_change_properties
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  /// Sets the filter.
  // ignore: use_setters_to_change_properties
  void setFilter(PdfFilter value) {
    filter.value = value;
  }

  /// Sets the sort order.
  // ignore: use_setters_to_change_properties
  void setSortOrder(PdfSort value) {
    sortOrder.value = value;
  }
}

/// PDF filter options.
enum PdfFilter {
  /// All files.
  all,

  /// Favorites only.
  favorites,

  /// Created files.
  created,

  /// Imported files.
  imported,
}

/// PDF sort options.
enum PdfSort {
  /// Newest first.
  newest,

  /// Oldest first.
  oldest,

  /// Name A-Z.
  nameAsc,

  /// Name Z-A.
  nameDesc,

  /// Largest first.
  largest,

  /// Smallest first.
  smallest,
}
