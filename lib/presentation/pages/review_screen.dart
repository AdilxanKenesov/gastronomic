import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/device_id_helper.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/review.dart';
import '../../data/datasources/remote/review_remote_datasource.dart';
import '../bloc/settings_bloc.dart';

class ReviewScreen extends StatefulWidget {
  final Restaurant restaurant;

  const ReviewScreen({super.key, required this.restaurant});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _selectedStars = 0;
  bool _isSubmitting = false;
  bool _isLoadingQuestions = true;
  String? _questionsError;
  List<ReviewQuestion> _questions = [];

  final ReviewRemoteDatasource _reviewService = ReviewRemoteDatasource();
  final Map<int, Set<int>> _selectedOptions = {};
  final Map<int, TextEditingController> _textControllers = {};
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuestions());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final language = context.read<SettingsBloc>().state.apiLanguage;
    setState(() {
      _isLoadingQuestions = true;
      _questionsError = null;
    });
    try {
      final questions = await _reviewService.getQuestions(language: language);
      if (!mounted) return;
      // Dispose old controllers
      for (final c in _textControllers.values) {
        c.dispose();
      }
      _textControllers.clear();
      setState(() {
        _questions = questions;
        _isLoadingQuestions = false;
        for (final q in questions) {
          if (q.options.isEmpty) {
            _textControllers[q.id] = TextEditingController();
          }
          for (final sub in q.subQuestions) {
            if (sub.options.isEmpty) {
              _textControllers[sub.id] = TextEditingController();
            }
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _questionsError = e.toString();
        _isLoadingQuestions = false;
      });
    }
  }

  /// overall_satisfied = rating sub-questionlari bo'lgan birinchi savol
  ReviewQuestion? get _ratingQuestion {
    for (final q in _questions) {
      if (q.subQuestions.any((s) => s.condition?.field == 'rating')) return q;
    }
    return _questions.isNotEmpty ? _questions.first : null;
  }

  List<ReviewQuestion> get _otherQuestions {
    final rq = _ratingQuestion;
    if (rq == null) return [];
    return _questions.where((q) => q.id != rq.id).toList();
  }

  bool _isSubQuestionVisible(SubQuestion sub) {
    final c = sub.condition;
    if (c == null) return true;
    if (c.field != 'rating' || _selectedStars == 0) return false;
    switch (c.operator) {
      case '<=':
        return _selectedStars <= c.value;
      case '>=':
        return _selectedStars >= c.value;
      case '<':
        return _selectedStars < c.value;
      case '>':
        return _selectedStars > c.value;
      case '==':
        return _selectedStars == c.value;
      default:
        return false;
    }
  }

  void _toggleOption(int questionId, int optionId, bool allowMultiple) {
    setState(() {
      final current = _selectedOptions[questionId] ?? {};
      if (current.contains(optionId)) {
        current.remove(optionId);
      } else {
        if (!allowMultiple) current.clear();
        current.add(optionId);
      }
      _selectedOptions[questionId] = current;
    });
  }

  void _onStarsChanged(int stars) {
    setState(() {
      _selectedStars = stars;
      // Reyting o'zgarganda sub-savollarni tozalash
      final rq = _ratingQuestion;
      if (rq != null) {
        for (final sub in rq.subQuestions) {
          _selectedOptions.remove(sub.id);
          _textControllers[sub.id]?.clear();
        }
      }
    });
  }

  Future<void> _submitReview() async {
    if (_selectedStars == 0) return;

    final l10n = AppLocalizations.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSubmitting = true);

    try {
      final deviceId = await DeviceIdHelper.getDeviceId();

      // Barcha tanlangan option ID'larini yig'ish
      final allOptionIds = <int>[];
      for (final ids in _selectedOptions.values) {
        allOptionIds.addAll(ids);
      }

      // Text inputlardan comment yaratish
      final textParts = <String>[];
      final rq = _ratingQuestion;
      for (final q in _questions) {
        if (rq != null && q.id == rq.id) {
          // Sub-savollarning text javoblarini qo'shish
          for (final sub in q.subQuestions) {
            if (!_isSubQuestionVisible(sub)) continue;
            final ctrl = _textControllers[sub.id];
            if (ctrl != null && ctrl.text.trim().isNotEmpty) {
              textParts.add('${sub.title}\n→ ${ctrl.text.trim()}');
            }
          }
          continue;
        }
        final ctrl = _textControllers[q.id];
        if (ctrl != null && ctrl.text.trim().isNotEmpty) {
          textParts.add('${q.title}\n→ ${ctrl.text.trim()}');
        }
      }

      final phone = _phoneController.text.trim();

      await _reviewService.createReview(
        restaurantId: widget.restaurant.id,
        deviceId: deviceId,
        rating: _selectedStars,
        comment: textParts.isNotEmpty ? textParts.join('\n\n') : null,
        phone: phone.isNotEmpty ? phone : null,
        selectedOptionIds: allOptionIds.isNotEmpty ? allOptionIds : null,
      );

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.translate('review_submitted')),
            backgroundColor: AppColors.success,
          ),
        );
        navigator.pop(true);
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
            ),
          ),
        ),
      ),
      body: _isLoadingQuestions
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _questionsError != null
              ? _buildErrorState(l10n)
              : _buildForm(l10n),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
        child: ElevatedButton(
          onPressed: _selectedStars > 0 && !_isSubmitting && !_isLoadingQuestions
              ? _submitReview
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.textOnPrimary,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  l10n.translate('submit_review'),
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              l10n.translate('error_loading'),
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadQuestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                l10n.translate('retry'),
                style: const TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final rq = _ratingQuestion;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: widget.restaurant.brand?.logoUrl != null
                      ? Image.network(
                          widget.restaurant.brand!.logoUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.restaurant,
                            size: 40,
                            color: AppColors.iconSecondary,
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          size: 40,
                          color: AppColors.iconSecondary,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Restaurant name
            Center(
              child: Text(
                widget.restaurant.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                widget.restaurant.category?.name ?? l10n.translate('restaurant'),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),

            // Intro
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                l10n.translate('review_intro'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Stars
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return Padding(
                    padding: EdgeInsets.only(right: i == 4 ? 0 : 5),
                    child: GestureDetector(
                      onTap: () => _onStarsChanged(i + 1),
                      child: Icon(
                        Icons.star_rounded,
                        size: 44,
                        color: i < _selectedStars ? AppColors.starRating : AppColors.border,
                      ),
                    ),
                  );
                }),
              ),
            ),

            if (_selectedStars > 0) ...[
              const SizedBox(height: 28),

              // Rating question sub-savollar (shartli ko'rsatish)
              if (rq != null)
                ...rq.subQuestions.where(_isSubQuestionVisible).expand((sub) => [
                      _buildSectionCard(
                        title: sub.isRequired ? '${sub.title} *' : sub.title,
                        child: sub.options.isEmpty && _textControllers.containsKey(sub.id)
                            ? _buildTextField(
                                controller: _textControllers[sub.id]!,
                                hint: l10n.translate('write_here_optional'),
                              )
                            : _buildOptionsChips(sub.id, sub.options, sub.allowMultiple),
                      ),
                      const SizedBox(height: 16),
                    ]),

              // Qolgan asosiy savollar
              ..._otherQuestions.expand((q) => [
                    _buildSectionCard(
                      title: q.isRequired ? '${q.title} *' : q.title,
                      child: q.options.isEmpty && _textControllers.containsKey(q.id)
                          ? _buildTextField(
                              controller: _textControllers[q.id]!,
                              hint: l10n.translate('write_here_optional'),
                            )
                          : _buildOptionsChips(q.id, q.options, q.allowMultiple),
                    ),
                    const SizedBox(height: 16),
                  ]),

              // Telefon raqam (ixtiyoriy)
              _buildSectionCard(
                title: l10n.translate('phone'),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 20,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '+998 XX XXX XX XX',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                    counterText: '',
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Rahmat matni
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Text(
                  l10n.translate('review_thanks'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),
            ] else ...[
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsChips(int questionId, List<QuestionOption> options, bool allowMultiple) {
    final selected = _selectedOptions[questionId] ?? {};
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected.contains(opt.id);
        return GestureDetector(
          onTap: () => _toggleOption(questionId, opt.id, allowMultiple),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt.text,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 3,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
    );
  }
}