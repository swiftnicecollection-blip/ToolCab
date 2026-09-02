import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

/// Service for QR code and barcode scanning using Google ML Kit.
///
/// Processes images locally on-device to detect QR codes and barcodes.
class QrScannerService {
  /// Barcode scanner instance.
  BarcodeScanner? _scanner;

  /// Whether the service has been initialized.
  bool _initialized = false;

  /// Initializes the barcode scanner.
  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }
    try {
      _scanner = BarcodeScanner(
        formats: <BarcodeFormat>[
          BarcodeFormat.qrCode,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upca,
          BarcodeFormat.upce,
        ],
      );
      _initialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Scans an image file for QR codes and barcodes.
  ///
  /// Returns the first detected barcode value, or null if none found.
  Future<String?> scanImage(String imagePath) async {
    if (!_initialized) {
      final bool ok = await initialize();
      if (!ok) {
        return null;
      }
    }

    try {
      final InputImage inputImage = InputImage.fromFilePath(imagePath);
      final List<Barcode> barcodes = await _scanner!.processImage(inputImage);
      if (barcodes.isEmpty) {
        return null;
      }
      return barcodes.first.rawValue;
    } catch (_) {
      return null;
    }
  }

  /// Scans an image from gallery for QR codes.
  ///
  /// Returns the first detected barcode value, or null if none found.
  Future<String?> scanFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
      if (image == null) {
        return null;
      }
      return scanImage(image.path);
    } catch (_) {
      return null;
    }
  }

  /// Disposes the scanner and releases resources.
  Future<void> dispose() async {
    if (_initialized && _scanner != null) {
      await _scanner!.close();
      _initialized = false;
      _scanner = null;
    }
  }
}
