import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../bloc/settings_bloc.dart';
import 'main_screen.dart';
import 'dart:math';

class IntroScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const IntroScreen({super.key, required this.prefs});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color bgColor = const Color(0xFFF2F6FA);
  final Color primaryBlue = const Color(0xFF0049DB);
  final Color descriptionColor = const Color(0xFF687792);

  final List<IntroPageData> _pages = [
    IntroPageData(
      image: 'assets/images/img4.png', // Biz siz uchun...
      title: 'Biz siz uchun Nukusning eng yaxshi joylarini saralab qo\'ydik.',
      description: 'Shaharning eng sara, tekshirilgan va yuqori reytingli restoranlari — bitta ilovada jamlandi.',
    ),
    IntroPageData(
      image: 'assets/images/img1.png', // Nukusning eng sara...
      title: 'Nukusning eng sara ta\'mini kashf eting',
      description: 'Shahardagi eng yaxshi va sertifikatlangan restoranlarni oson toping.',
    ),
    IntroPageData(
      image: 'assets/images/img2.png', // Menyu va narxlarni...
      title: 'Menyu va narxlarni oldindan ko\'ring',
      description: 'Buyurtma berishdan oldin taomlar rasmi va tarkibi bilan tanishing.',
    ),
    IntroPageData(
      image: 'assets/images/img3.png',
      title: 'Haqiqiy baho va sharhlar',
      description: 'Xizmat sifatini baholang va boshqalar fikrini o\'qing.',
    ),
  ];

  Future<void> _completeIntro() async {
    await widget.prefs.setBool('has_seen_intro', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final screenHeight = MediaQuery.of(modalContext).size.height;
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (blocContext, state) {
            return Container(
              height: screenHeight * 0.55,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(modalContext),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            l10n.translate('select_language'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  _buildLangOption(context, label: 'Qaraqalpaqsha', code: 'kaa', assetPath: 'assets/images/qr.png', isSelected: state.languageCode == 'kaa'),
                  _buildLangOption(context, label: 'O\'zbekcha',    code: 'uz',  assetPath: 'assets/images/uz.png', isSelected: state.languageCode == 'uz'),
                  _buildLangOption(context, label: 'Русский',       code: 'ru',  assetPath: 'assets/images/ru.png', isSelected: state.languageCode == 'ru'),
                  _buildLangOption(context, label: 'English',       code: 'en',  assetPath: 'assets/images/uk.png', isSelected: state.languageCode == 'en'),
                  const Spacer(),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLangOption(
    BuildContext context, {
    required String label,
    required String code,
    required String assetPath,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        final settingsBloc = context.read<SettingsBloc>();
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 100), () {
          settingsBloc.add(ChangeLanguage(code));
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.card : AppColors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5)
              : null,
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.shadow, blurRadius: 10)]
              : [],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                assetPath,
                width: 30,
                height: 20,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.flag, size: 25, color: AppColors.iconSecondary),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Rasmlar (Orqa fonda)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(height: 60),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(_pages[index].image, fit: BoxFit.contain),
                    ),
                  ),
                  const Spacer(flex: 4), // Matn kartasi uchun joy
                ],
              );
            },
          ),

          // Language button (har doim ko'rinadi — top-left)
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => _showLanguageBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.language_rounded, color: primaryBlue, size: 22),
              ),
            ),
          ),

          // 2. Progress Circle (Faqat 1-sahifadan keyin)
          if (_currentPage > 0)
            Positioned(
              top: 50,
              right: 25,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  currentStep: _currentPage, // 1/3, 2/3, 3/3 ko'rinishi uchun
                  totalSteps: _pages.length - 1,
                  color: primaryBlue,
                ),
                child: Container(
                  width: 45,
                  height: 45,
                  alignment: Alignment.center,
                  child: Text(
                    '$_currentPage/${_pages.length - 1}',
                    style: TextStyle(color: descriptionColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pages[_currentPage].title,
                    style: TextStyle(color: primaryBlue, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _pages[_currentPage].description,
                    style: TextStyle(color: descriptionColor, fontSize: 15, height: 1.4),
                  ),
                  const Spacer(),
                  // Tugmalar kartaning ichida, eng pastda
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0), // SHU YERDA: Tugmalarni pastdan ko'tarish
                    child: _buildButtons(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_currentPage == 0) {
      // Birinchi sahifa: Ikkita tugma
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _completeIntro,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryBlue, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text('O\'tkazib yuborish', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: const Text('Oldinga', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (_currentPage < _pages.length - 1) {
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
            } else {
              _completeIntro();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: Text(
            _currentPage == _pages.length - 1 ? 'Ro\'yxatdan o\'tish' : 'Oldinga',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      );
    }
  }
}

class CircularProgressPainter extends CustomPainter {
  final int currentStep;
  final int totalSteps;
  final Color color;

  CircularProgressPainter({required this.currentStep, required this.totalSteps, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint circle = Paint()..color = const Color(0xFFE0E0E0)..strokeWidth = 4..style = PaintingStyle.stroke;
    Paint arc = Paint()..color = color..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, circle);

    double sweepAngle = (2 * pi * currentStep) / totalSteps;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweepAngle, false, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class IntroPageData {
  final String image;
  final String title;
  final String description;
  IntroPageData({required this.image, required this.title, required this.description});
}