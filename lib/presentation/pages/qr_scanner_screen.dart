import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/datasources/remote/restaurant_remote_datasource.dart';
import 'restaurant_detail_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final bool isActive; // Yangi qo'shildi
  final VoidCallback? onNavigateAway;

  const QRScannerScreen({
    super.key, 
    required this.isActive, // Majburiy qilindi
    this.onNavigateAway,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final RestaurantRemoteDatasource _restaurantService = RestaurantRemoteDatasource();

  bool _isScanning = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _isLoading) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        _processQRCode(code);
      }
    }
  }

  Future<void> _processQRCode(String code) async {
    setState(() {
      _isScanning = false;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final int? restaurantId = _parseRestaurantId(code);

      if (restaurantId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'invalid_qr';
        });
        return;
      }

      final restaurant = await _restaurantService.getRestaurantDetail(id: restaurantId);

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
          ),
        );
        widget.onNavigateAway?.call();
        _resetScanner();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'restaurant_not_found';
        });
      }
    }
  }

  int? _parseRestaurantId(String code) {
    final directId = int.tryParse(code.trim());
    if (directId != null) return directId;

    final urlPattern = RegExp(r'/restaurants?/(\d+)');
    final urlMatch = urlPattern.firstMatch(code);
    if (urlMatch != null) {
      return int.tryParse(urlMatch.group(1)!);
    }

    final numberPattern = RegExp(r'(\d+)');
    final matches = numberPattern.allMatches(code);
    if (matches.isNotEmpty) {
      return int.tryParse(matches.last.group(1)!);
    }

    return null;
  }

  void _resetScanner() {
    if (!mounted) return;

    setState(() {
      _isScanning = true;
      _isLoading = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Faqat ekran faol bo'lgandagina kamerani yoqamiz
          if (widget.isActive)
            MobileScanner(
              onDetect: _onDetect,
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),

          if (_isLoading)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.58,
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.translate('loading'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          if (_errorMessage != null && !_isLoading)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.58,
              child: _buildErrorView(l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _errorMessage == 'invalid_qr'
              ? l10n.translate('invalid_qr_code')
              : l10n.translate('no_restaurants'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: GestureDetector(
            onTap: _resetScanner,
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                l10n.translate('retry'),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.75;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2.5;

    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
          const Radius.circular(24),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(24),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
