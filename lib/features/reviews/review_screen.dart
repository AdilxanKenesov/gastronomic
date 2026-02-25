import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/device_id_helper.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/services/review_service.dart';

class ReviewScreen extends StatefulWidget {
  final Restaurant restaurant;

  const ReviewScreen({super.key, required this.restaurant});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _selectedStars = 0;
  bool _isSubmitting = false;
  final ReviewService _reviewService = ReviewService();

  // Low rating (1–3)
  final Set<String> _lowA = {};
  final TextEditingController _lowAOtherController = TextEditingController();
  final Set<String> _lowB = {};
  final TextEditingController _lowCController = TextEditingController();

  // High rating (4–5)
  final Set<String> _highA = {};
  final TextEditingController _highAOtherController = TextEditingController();
  final TextEditingController _highBController = TextEditingController();
  final TextEditingController _highCController = TextEditingController();

  // General questions
  String? _visitCategory;
  String? _willReturn;
  final TextEditingController _additionalCommentsController = TextEditingController();

  @override
  void dispose() {
    _lowAOtherController.dispose();
    _lowCController.dispose();
    _highAOtherController.dispose();
    _highBController.dispose();
    _highCController.dispose();
    _additionalCommentsController.dispose();
    super.dispose();
  }

  void _onStarsChanged(int stars) {
    setState(() {
      _selectedStars = stars;
      _lowA.clear();
      _lowAOtherController.clear();
      _lowB.clear();
      _lowCController.clear();
      _highA.clear();
      _highAOtherController.clear();
      _highBController.clear();
      _highCController.clear();
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

      // "Savol\n→ Javob" formatida blok yaratadi
      String qa(String question, String answer) => '$question\n→ $answer';

      final List<String> parts = [];

      if (_selectedStars <= 3) {
        // A: nima yoqmadi (multi-select + other)
        final List<String> aAnswers = [];
        if (_lowA.isNotEmpty) {
          aAnswers.add(_lowA.map((k) => l10n.translate(k)).join(', '));
        }
        if (_lowAOtherController.text.trim().isNotEmpty) {
          aAnswers.add('${l10n.translate('other')}: ${_lowAOtherController.text.trim()}');
        }
        if (aAnswers.isNotEmpty) {
          parts.add(qa('A. ${l10n.translate('low_rating_a_title')}', aAnswers.join('\n→ ')));
        }

        // B: nima norozilik keltirdi
        if (_lowB.isNotEmpty) {
          final texts = _lowB.map((k) => l10n.translate(k)).join(', ');
          parts.add(qa('B. ${l10n.translate('low_rating_b_title')}', texts));
        }

        // C: nima yaxshilanishi mumkin
        if (_lowCController.text.trim().isNotEmpty) {
          parts.add(qa('C. ${l10n.translate('low_rating_c_title')}', _lowCController.text.trim()));
        }
      } else {
        // A: nima yoqdi (multi-select + other)
        final List<String> aAnswers = [];
        if (_highA.isNotEmpty) {
          aAnswers.add(_highA.map((k) => l10n.translate(k)).join(', '));
        }
        if (_highAOtherController.text.trim().isNotEmpty) {
          aAnswers.add('${l10n.translate('other')}: ${_highAOtherController.text.trim()}');
        }
        if (aAnswers.isNotEmpty) {
          parts.add(qa('A. ${l10n.translate('high_rating_a_title')}', aAnswers.join('\n→ ')));
        }

        // B: nima esda qoldi
        if (_highBController.text.trim().isNotEmpty) {
          parts.add(qa('B. ${l10n.translate('high_rating_b_title')}', _highBController.text.trim()));
        }

        // C: nima yaxshilanishi mumkin edi
        if (_highCController.text.trim().isNotEmpty) {
          parts.add(qa('C. ${l10n.translate('high_rating_c_title')}', _highCController.text.trim()));
        }
      }

      // Umumiy savollar
      if (_visitCategory != null) {
        parts.add(qa('1. ${l10n.translate('general_q1_title')}', l10n.translate(_visitCategory!)));
      }
      if (_willReturn != null) {
        parts.add(qa('2. ${l10n.translate('general_q2_title')}', l10n.translate(_willReturn!)));
      }
      if (_additionalCommentsController.text.trim().isNotEmpty) {
        parts.add(qa('3. ${l10n.translate('general_q3_title')}', _additionalCommentsController.text.trim()));
      }

      final comment = parts.join('\n\n');

      await _reviewService.createReview(
        restaurantId: widget.restaurant.id,
        deviceId: deviceId,
        rating: _selectedStars,
        comment: comment.isNotEmpty ? comment : null,
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
      body: SingleChildScrollView(
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
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.restaurant,
                                size: 40,
                                color: AppColors.iconSecondary,
                              );
                            },
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

              // Restaurant name and category
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Intro text
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
                  children: List.generate(5, (index) {
                    final isSelected = index < _selectedStars;
                    return Padding(
                      padding: EdgeInsets.only(right: index == 4 ? 0 : 5),
                      child: GestureDetector(
                        onTap: () => _onStarsChanged(index + 1),
                        child: Icon(
                          Icons.star_rounded,
                          size: 44,
                          color: isSelected ? AppColors.starRating : AppColors.border,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              if (_selectedStars > 0) ...[
                const SizedBox(height: 28),

                if (_selectedStars <= 3) ...[
                  // ── LOW RATING SECTIONS ──────────────────────────────────

                  // A: What didn't you like?
                  _buildSectionCard(
                    title: '${l10n.translate('low_rating_a_title')}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMultiSelectOptions(
                          keys: const [
                            'low_a_slow_service',
                            'low_a_rude_staff',
                            'low_a_order_errors',
                            'low_a_cleanliness',
                            'low_a_noisy',
                            'low_a_bad_lighting',
                            'low_a_uncomfortable_seating',
                          ],
                          selectedSet: _lowA,
                          l10n: l10n,
                          onToggle: (key) => setState(() {
                            if (_lowA.contains(key)) {
                              _lowA.remove(key);
                            } else {
                              _lowA.add(key);
                            }
                          }),
                        ),
                        const SizedBox(height: 10),
                        _buildOtherTextField(controller: _lowAOtherController, l10n: l10n),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // B: What specifically caused dissatisfaction?
                  _buildSectionCard(
                    title: '${l10n.translate('low_rating_b_title')}',
                    child: _buildMultiSelectOptions(
                      keys: const [
                        'low_b_food_quality',
                        'low_b_wait_time',
                        'low_b_staff_politeness',
                        'low_b_atmosphere',
                        'low_b_price_quality',
                      ],
                      selectedSet: _lowB,
                      l10n: l10n,
                      onToggle: (key) => setState(() {
                        if (_lowB.contains(key)) {
                          _lowB.remove(key);
                        } else {
                          _lowB.add(key);
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // C: What can be improved?
                  _buildSectionCard(
                    title: 'C. ${l10n.translate('low_rating_c_title')}',
                    child: _buildTextField(
                      controller: _lowCController,
                      hint: l10n.translate('write_here_optional'),
                    ),
                  ),
                ] else ...[
                  // ── HIGH RATING SECTIONS ─────────────────────────────────

                  // A: What did you like?
                  _buildSectionCard(
                    title: '${l10n.translate('high_rating_a_title')}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMultiSelectOptions(
                          keys: const [
                            'high_a_food_taste',
                            'high_a_food_presentation',
                            'high_a_polite_staff',
                            'high_a_fast_service',
                            'high_a_comfortable_atmosphere',
                            'high_a_cleanliness',
                            'high_a_convenient_location',
                          ],
                          selectedSet: _highA,
                          l10n: l10n,
                          onToggle: (key) => setState(() {
                            if (_highA.contains(key)) {
                              _highA.remove(key);
                            } else {
                              _highA.add(key);
                            }
                          }),
                        ),
                        const SizedBox(height: 10),
                        _buildOtherTextField(controller: _highAOtherController, l10n: l10n),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // B: What was especially memorable?
                  _buildSectionCard(
                    title: '${l10n.translate('high_rating_b_title')}',
                    child: _buildTextField(
                      controller: _highBController,
                      hint: l10n.translate('write_here_optional'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // C: What could be improved?
                  _buildSectionCard(
                    title: '${l10n.translate('high_rating_c_title')}',
                    child: _buildTextField(
                      controller: _highCController,
                      hint: l10n.translate('write_here_optional'),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                _buildSectionCard(
                  title: '1. ${l10n.translate('general_q1_title')}',
                  child: _buildSingleSelectOptions(
                    keys: const [
                      'visit_breakfast',
                      'visit_lunch',
                      'visit_dinner',
                      'visit_coffee',
                      'visit_dessert',
                      'visit_other',
                    ],
                    selected: _visitCategory,
                    l10n: l10n,
                    onSelect: (key) => setState(() {
                      _visitCategory = _visitCategory == key ? null : key;
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Will you return?
                _buildSectionCard(
                  title: '2. ${l10n.translate('general_q2_title')}',
                  child: _buildSingleSelectOptions(
                    keys: const ['return_yes', 'return_maybe', 'return_no'],
                    selected: _willReturn,
                    l10n: l10n,
                    onSelect: (key) => setState(() {
                      _willReturn = _willReturn == key ? null : key;
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Additional comments
                _buildSectionCard(
                  title: '3. ${l10n.translate('general_q3_title')}',
                  child: _buildTextField(
                    controller: _additionalCommentsController,
                    hint: l10n.translate('write_here_optional'),
                  ),
                ),

                const SizedBox(height: 20),

                // Thank you text
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
        child: ElevatedButton(
          onPressed: _selectedStars > 0 && !_isSubmitting ? _submitReview : null,
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

  Widget _buildMultiSelectOptions({
    required List<String> keys,
    required Set<String> selectedSet,
    required AppLocalizations l10n,
    required void Function(String) onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keys.map((key) {
        final isSelected = selectedSet.contains(key);
        return GestureDetector(
          onTap: () => onToggle(key),
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
              l10n.translate(key),
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

  Widget _buildSingleSelectOptions({
    required List<String> keys,
    required String? selected,
    required AppLocalizations l10n,
    required void Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keys.map((key) {
        final isSelected = selected == key;
        return GestureDetector(
          onTap: () => onSelect(key),
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
              l10n.translate(key),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 3,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
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

  Widget _buildOtherTextField({
    required TextEditingController controller,
    required AppLocalizations l10n,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${l10n.translate('other')}:',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: l10n.translate('write_here_optional'),
              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              isDense: true,
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
      ],
    );
  }
}