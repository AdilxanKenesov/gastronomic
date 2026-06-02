import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/l10n/app_localizations.dart';
import '../bloc/settings_bloc.dart';
import 'main_screen.dart';

class IntroScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const IntroScreen({super.key, required this.prefs});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<IntroPageData> _buildPages(AppLocalizations l10n) => [
    IntroPageData(
      image: 'assets/images/img4.png',
      title: l10n.translate('intro_title_1'),
      description: l10n.translate('intro_desc_1'),
    ),
    IntroPageData(
      image: 'assets/images/img1.png',
      title: l10n.translate('intro_title_2'),
      description: l10n.translate('intro_desc_2'),
    ),
    IntroPageData(
      image: 'assets/images/img2.png',
      title: l10n.translate('intro_title_3'),
      description: l10n.translate('intro_desc_3'),
    ),
    IntroPageData(
      image: 'assets/images/img3.png',
      title: l10n.translate('intro_title_4'),
      description: l10n.translate('intro_desc_4'),
    ),
  ];

  Future<void> _completeIntro() async {
    await widget.prefs.setBool('has_seen_intro', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => const MainScreen(),
        transitionsBuilder: (context, animation, _, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          // Yangi ekran o'ngdan chapga yengil suzib kiradi (fade bilan).
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.35, 0), // o'ngda boshlanadi
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _goNext(List<IntroPageData> pages) {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeIntro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final l10n = AppLocalizations.of(context);
        final pages = _buildPages(l10n);
        final size = MediaQuery.of(context).size;
        final topPad = MediaQuery.of(context).padding.top;
        final sheetHeight = size.height * 0.46;
        final isLast = _currentPage == pages.length - 1;

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: Stack(
            children: [
              // ── Soft olive glow behind the hero image ──────────
              Positioned(
                top: topPad + 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: size.width * 0.82,
                    height: size.width * 0.82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.12),
                          AppColors.cream.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Hero images (swipeable) ────────────────────────
              PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SizedBox(height: topPad + 88),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 34),
                          child: Image.asset(pages[index].image, fit: BoxFit.contain),
                        ),
                      ),
                      SizedBox(height: sheetHeight - 28),
                    ],
                  );
                },
              ),

              // ── Language pill (top-left) ───────────────────────
              Positioned(
                top: topPad + 8,
                left: 20,
                child: _circleButton(
                  icon: Icons.language_rounded,
                  onTap: () => _showLanguageBottomSheet(context),
                ),
              ),

              // ── Skip (top-right, hidden on last page) ──────────
              if (!isLast)
                Positioned(
                  top: topPad + 12,
                  right: 20,
                  child: GestureDetector(
                    onTap: _completeIntro,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Text(
                        l10n.translate('skip'),
                        style: AppText.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Bottom content sheet ───────────────────────────
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: sheetHeight,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.10),
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDots(pages.length),
                      const SizedBox(height: 22),
                      // Sarlavha + tavsif — rasm bilan birga o'ngdan chapga
                      // silliq suriladi (PageController surilishi bilan sinxron).
                      Expanded(
                        child: ClipRect(
                          child: AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, _) {
                              double page = _currentPage.toDouble();
                              if (_pageController.hasClients &&
                                  _pageController.position.haveDimensions) {
                                page = _pageController.page ?? page;
                              }
                              final width = MediaQuery.of(context).size.width;
                              return Stack(
                                children: [
                                  for (int i = 0; i < pages.length; i++)
                                    _buildPageText(pages[i], i, page, width),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      _buildButtons(l10n, pages, isLast),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bitta intro sahifaning matni (sarlavha + tavsif).
  /// [page] — PageView'ning joriy (kasrli) holati. Matn rasm bilan birga
  /// o'ngdan chapga suriladi va surilish davomida asta-sekin so'nadi (fade).
  Widget _buildPageText(IntroPageData data, int index, double page, double width) {
    final delta = index - page; // 0 = joriy, >0 = hali o'ngda, <0 = chapga ketgan
    final opacity = (1 - delta.abs()).clamp(0.0, 1.0);
    if (opacity == 0) return const SizedBox.shrink();
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(delta * width * 0.5, 0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: AppText.serif(
                  fontSize: 29,
                  color: AppColors.textPrimary,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                data.description,
                style: AppText.sans(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots(int count) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 6),
          width: active ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }

  Widget _buildButtons(AppLocalizations l10n, List<IntroPageData> pages, bool isLast) {
    final nextLabel = isLast ? l10n.translate('intro_get_started') : l10n.translate('next');
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _goNext(pages),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nextLabel,
              style: AppText.sans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
              size: 20,
              color: AppColors.textOnPrimary,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Language bottom sheet ────────────────────────────────────
  void _showLanguageBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (blocContext, state) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                      child: Text(
                        l10n.translate('select_language'),
                        style: AppText.serif(fontSize: 24, color: AppColors.textPrimary),
                      ),
                    ),
                    _buildLangOption(context, label: 'Qaraqalpaqsha', code: 'kaa', assetPath: 'assets/images/qr.png', isSelected: state.languageCode == 'kaa'),
                    _buildLangOption(context, label: 'O\'zbekcha', code: 'uz', assetPath: 'assets/images/uz.png', isSelected: state.languageCode == 'uz'),
                    _buildLangOption(context, label: 'Русский', code: 'ru', assetPath: 'assets/images/ru.png', isSelected: state.languageCode == 'ru'),
                    _buildLangOption(context, label: 'English', code: 'en', assetPath: 'assets/images/uk.png', isSelected: state.languageCode == 'en'),
                    const SizedBox(height: 16),
                  ],
                ),
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
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.shadow, blurRadius: 10)]
              : null,
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
                    const Icon(Icons.flag, size: 24, color: AppColors.iconSecondary),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: AppText.sans(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

class IntroPageData {
  final String image;
  final String title;
  final String description;
  IntroPageData({required this.image, required this.title, required this.description});
}
