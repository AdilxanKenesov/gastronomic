import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final EdgeInsets padding;

  const LoadingIndicator({
    super.key,
    this.padding = const EdgeInsets.all(40),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: const CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

/// Error state widget with retry button
class ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;
  final EdgeInsets padding;

  const ErrorState({
    super.key,
    required this.onRetry,
    this.message,
    this.padding = const EdgeInsets.all(40),
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? l10n.translate('error_loading'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: Text(l10n.translate('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final String? message;
  final IconData icon;
  final EdgeInsets padding;

  const EmptyState({
    super.key,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.padding = const EdgeInsets.all(40),
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? l10n.translate('nothing_found'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}