import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import 'bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                l10n.translate('settings'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildMenuCard(
                    context,
                    title: l10n.translate('language'),
                    icon: Icons.public,
                    iconColor: AppColors.iconSuccess,
                    onTap: () => _showLanguageBottomSheet(context),
                  ),
                  const SizedBox(width: 16),
                  _buildMenuCard(
                    context,
                    title: l10n.translate('about_app'),
                    icon: Icons.info,
                    iconColor: AppColors.iconSecondary,
                    onTap: () => _showAboutAppDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        // Modal context ni ishlatamiz - bu xavfsizroq
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
                        _buildBackButton(context),
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
                  // Tillar ro'yxati
                  _buildLangOption(
                    context,
                    label: 'Qaraqalpaqsha',
                    code: 'kaa',
                    assetPath: 'assets/images/qr.png',
                    isSelected: state.languageCode == 'kaa',
                  ),
                  _buildLangOption(
                    context,
                    label: 'O\'zbekcha',
                    code: 'uz',
                    assetPath: 'assets/images/uz.png',
                    isSelected: state.languageCode == 'uz',
                  ),
                  _buildLangOption(
                    context,
                    label: 'Русский',
                    code: 'ru',
                    assetPath: 'assets/images/ru.png',
                    isSelected: state.languageCode == 'ru',
                  ),
                  _buildLangOption(
                    context,
                    label: 'English',
                    code: 'en',
                    assetPath: 'assets/images/uk.png',
                    isSelected: state.languageCode == 'en',
                  ),
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
        // Bloc ni async gap oldidan olamiz
        final settingsBloc = context.read<SettingsBloc>();
        // Avval bottom sheet yopiladi, keyin til o'zgaradi
        Navigator.pop(context);
        // Kichik kutish - bottom sheet to'liq yopilishi uchun
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
                errorBuilder: (context, error, stackTrace) =>
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

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(icon, color: iconColor, size: 45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildBackButton(context),
                  Expanded(
                    child: Text(
                      l10n.translate('about_app'),
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
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    l10n.translate('about_description'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  'assets/images/logo1.png',
                  'assets/images/logo2.png',
                  'assets/images/logo3.png',
                ].map((path) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      path,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_balance,
                        color: AppColors.iconSecondary,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}