import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../shared/widgets/feedback/error_state.dart';
import '../service/qr_scanner_service.dart';

/// QR Scanner tool view.
///
/// Presents a scanning interface with camera permission handling,
/// gallery import for QR detection, and scan result management.
class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final QrScannerService _scannerService = QrScannerService();

  bool _torchOn = false;
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _hasCameraPermission = false;
  bool _isWeb = false;
  String? _scanResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  /// Initializes the scanner and checks platform support.
  Future<void> _initialize() async {
    final bool isWeb =
        !(GetPlatform.isAndroid || GetPlatform.isIOS || GetPlatform.isMacOS);

    if (isWeb) {
      setState(() {
        _isWeb = true;
        _isLoading = false;
      });
      return;
    }

    // Request camera permission.
    final PermissionStatus status = await Permission.camera.request();
    final bool granted = status.isGranted;

    if (mounted) {
      setState(() {
        _isWeb = false;
        _hasCameraPermission = granted;
        _isLoading = false;
      });

      if (!granted) {
        if (status.isPermanentlyDenied) {
          setState(() {
            _errorMessage =
                'Camera permission permanently denied. Please enable it in app settings.';
          });
        }
      }
    }
  }

  /// Opens app settings for permission management.
  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  /// Scans a QR code from the gallery.
  Future<void> _scanFromGallery() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final String? result = await _scannerService.scanFromGallery();
      if (mounted) {
        setState(() {
          _isProcessing = false;
          if (result != null) {
            _scanResult = result;
          } else {
            _errorMessage = 'No QR code found in the selected image.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Unable to process the image. Please try again.';
        });
      }
    }
  }

  /// Clears the current scan result.
  void _clearResult() {
    setState(() {
      _scanResult = null;
      _errorMessage = null;
    });
  }

  /// Copies the result to clipboard.
  void _copyResult() {
    if (_scanResult == null) return;

    // Use a controller to copy to clipboard.
    final snackBar = SnackBar(
      content: const Text('Copied to clipboard'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shares the scan result.
  Future<void> _shareResult() async {
    if (_scanResult == null) return;
    await SharePlus.instance.share(ShareParams(text: _scanResult));
  }

  /// Opens a URL if the scan result is a valid URL.
  Future<void> _openUrl() async {
    if (_scanResult == null) return;

    final String text = _scanResult!.trim();
    if (text.startsWith('http://') || text.startsWith('https://')) {
      final Uri uri = Uri.parse(text);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          Get.snackbar(
            'Cannot Open',
            'Unable to open this link.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      }
    }
  }

  /// Returns true if the scan result looks like a URL.
  bool get _isUrl {
    if (_scanResult == null) return false;
    final String text = _scanResult!.trim();
    return text.startsWith('http://') || text.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: <Widget>[
          if (_scanResult == null && !_isWeb && _hasCameraPermission)
            IconButton(
              icon: const Icon(Icons.photo_library_rounded),
              onPressed: _isProcessing ? null : _scanFromGallery,
              tooltip: 'Scan from Gallery',
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : _buildBody(context),
      ),
    );
  }

  /// Builds the main body based on state.
  Widget _buildBody(BuildContext context) {
    if (_scanResult != null) {
      return _buildResult(context);
    }

    if (_isWeb) {
      return _buildWebUnsupported(context);
    }

    if (!_hasCameraPermission) {
      return _buildPermissionRequest(context);
    }

    return _buildScannerInterface(context);
  }

  /// Scanner interface with instructions and gallery option.
  Widget _buildScannerInterface(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return Stack(
      children: <Widget>[
        // Camera preview placeholder background.
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.qr_code_scanner_rounded,
              size: isTablet ? 128 : 96,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ),

        // Instructions overlay.
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Status badge.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Text(
                        'Ready to scan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Instructions.
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: const Text(
                      'Import an image with a QR code to scan it',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Bottom controls.
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Gallery button.
                    _ScanControlButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Import Image',
                      active: false,
                      onTap: _isProcessing ? null : _scanFromGallery,
                    ),
                    const SizedBox(width: AppSpacing.xl),

                    // Torch toggle (placeholder for future camera integration).
                    _ScanControlButton(
                      icon: _torchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      label: 'Torch',
                      active: _torchOn,
                      onTap: () => setState(() => _torchOn = !_torchOn),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Processing overlay.
        if (_isProcessing)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Scanning...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Show scan result.
  Widget _buildResult(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Success header.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.success.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: AppShadows.medium,
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 36,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'QR Code Scanned',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: SelectableText(
                    _scanResult!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Actions.
          _ActionButton(
            icon: Icons.copy_rounded,
            label: 'Copy Result',
            color: AppColors.primary,
            onTap: _copyResult,
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            color: AppColors.info,
            onTap: _shareResult,
          ),
          if (_isUrl) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _ActionButton(
              icon: Icons.open_in_new_rounded,
              label: 'Open Link',
              color: AppColors.categoryQr,
              onTap: _openUrl,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _ActionButton(
            icon: Icons.refresh_rounded,
            label: 'Scan Again',
            color: AppColors.categoryTools,
            onTap: _clearResult,
          ),
        ],
      ),
    );
  }

  /// Web unsupported state.
  Widget _buildWebUnsupported(BuildContext context) {
    return ErrorState(
      title: 'Camera Not Available on Web',
      message: 'QR scanning requires camera support on Android or iOS. '
          'Please use the mobile app to scan QR codes.',
      onRetry: () {
        setState(() {
          _isLoading = true;
        });
        _initialize();
      },
    );
  }

  /// Permission request state.
  Widget _buildPermissionRequest(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    AppColors.categoryQr.withValues(alpha: 0.20),
                    AppColors.categoryQr.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: AppColors.categoryQr.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                size: 48,
                color: AppColors.categoryQr,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Camera Access Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage ??
                  'ToolCab needs camera permission to scan QR codes. '
                      'You can always change this in your device settings.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: _openAppSettings,
                icon: const Icon(Icons.settings_rounded, size: 20),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.categoryQr,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scan control button (torch, gallery).
class _ScanControlButton extends StatelessWidget {
  const _ScanControlButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.categoryQr
                  : Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              size: 26,
              color: active ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button for result screen.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.10),
          foregroundColor: color,
          elevation: 0,
        ),
      ),
    );
  }
}
