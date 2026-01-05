import 'package:flutter/material.dart';
import '../../../controllers/recipe_suggestion_filters.dart';

/// Validation-focused filter dialog with red-stroked controls and alert banner.
class RecipeFiltersValidationView extends StatefulWidget {
  const RecipeFiltersValidationView({super.key, this.initial});

  final RecipeFilterOptions? initial;

  static Future<void> show(
    BuildContext context, {
    RecipeFilterOptions? initial,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => RecipeFiltersValidationView(initial: initial),
    );
  }

  @override
  State<RecipeFiltersValidationView> createState() =>
      _RecipeFiltersValidationViewState();
}

class _RecipeFiltersValidationViewState
    extends State<RecipeFiltersValidationView> {
  static const _accent = Color(0xFF4CAF50);
  static const _muted = Color(0xFF6B7280);
  static const _primaryRed = Color(0xFFDC2626);
  static const _summaryRed = Color(0xFFEF4444);
  static const _alertBg = Color(0xFFFEF2F2);
  static const _alertBorder = Color(0xFFFCA5A5);
  static const _grayBg = Color(0xFFF3F4F6);
  static const _grayBorder = Color(0xFFD1D5DB);

  late String _selectedTime;
  late Set<String> _selectedMeals;
  late Set<String> _selectedCuisines;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initial?.timeKey ?? '';
    _selectedMeals = Set<String>.from(widget.initial?.mealLabels ?? {});
    _selectedCuisines = Set<String>.from(widget.initial?.cuisineLabels ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth >= 768 ? 500.0 : 412.0;
        final cardWidth = (constraints.maxWidth - 32).clamp(0.0, maxWidth);
        final cardHeight = constraints.maxHeight * 0.9;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: cardWidth,
              maxHeight: cardHeight,
            ),
            child: Material(
              color: Colors.white,
              elevation: 12,
              borderRadius: BorderRadius.circular(20),
              shadowColor: Colors.black.withValues(alpha: 0.15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTimeSection(),
                              const SizedBox(height: 24),
                              _buildMealSection(),
                              const SizedBox(height: 24),
                              _buildCuisineSection(),
                              const SizedBox(height: 24),
                              _buildSummarySection(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFooterButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Bộ lọc gợi ý',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        _roundedIconButton(
          icon: Icons.close,
          onTap: () {
            final navigator = Navigator.of(context, rootNavigator: true);
            if (navigator.canPop()) navigator.pop(); // close validation dialog
            if (navigator.canPop())
              navigator
                  .pop(); // close default filter dialog, return to RecipeView
          },
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thời gian nấu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _radioOption('none', 'Không lọc'),
            _radioOption('under15', 'Dưới 15 phút'),
            _radioOption('15to30', '15–30 phút'),
            _radioOption('over30', 'Trên 30 phút'),
          ],
        ),
      ],
    );
  }

  Widget _buildMealSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại bữa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chipOption('Sáng'),
            _chipOption('Trưa'),
            _chipOption('Tối'),
            _chipOption('Bữa phụ'),
          ],
        ),
      ],
    );
  }

  Widget _buildCuisineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ẩm thực',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chipOption('Việt'),
            _chipOption('Á'),
            _chipOption('Âu'),
            _chipOption('Mỹ'),
            _chipOption('Chay'),
            _chipOption('Khác'),
          ],
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    final hasSelection =
        _selectedTime.isNotEmpty ||
        _selectedMeals.isNotEmpty ||
        _selectedCuisines.isNotEmpty;

    final Color iconColor = hasSelection ? _muted : _summaryRed;
    final Color textColor = hasSelection ? _muted : _summaryRed;
    final Color bgColor = hasSelection ? _grayBg : _alertBg;
    final BoxBorder? border = hasSelection
        ? null
        : Border.all(color: _alertBorder);
    final String text = hasSelection
        ? _buildSummaryText()
        : 'Bạn cần chọn đầy đủ các tuỳ chọn để được đưa ra gợi ý chính xác.';

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: border,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Row(
        children: [_clearButton(), const SizedBox(width: 12), _applyButton()],
      ),
    );
  }

  Widget _roundedIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
      ),
    );
  }

  Widget _radioOption(String value, String label) {
    final bool active = _selectedTime == value && _selectedTime.isNotEmpty;
    return GestureDetector(
      onTap: () => setState(() => _selectedTime = value),
      child: Container(
        height: 44,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active ? _accent : const Color(0xFFE5E7EB),
            width: 1.3,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accent, width: 2),
              ),
              child: Center(
                child: AnimatedOpacity(
                  opacity: active ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accent,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: active ? _accent : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipOption(String label) {
    final isSelected =
        _selectedMeals.contains(label) || _selectedCuisines.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedMeals.contains(label)) {
            _selectedMeals.remove(label);
          } else if (_selectedCuisines.contains(label)) {
            _selectedCuisines.remove(label);
          } else {
            if (['Sáng', 'Trưa', 'Tối', 'Bữa phụ'].contains(label)) {
              _selectedMeals.add(label);
            } else {
              _selectedCuisines.add(label);
            }
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F4EA) : _grayBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _accent : _grayBorder,
            width: 1.1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? _accent : _muted,
          ),
        ),
      ),
    );
  }

  Widget _clearButton() {
    return Expanded(
      child: SizedBox(
        height: 45,
        child: OutlinedButton(
          onPressed: _onClear,
          style: OutlinedButton.styleFrom(
            foregroundColor: _primaryRed,
            side: const BorderSide(color: _primaryRed),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text(
            'Xóa bộ lọc',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _applyButton() {
    return Expanded(
      child: SizedBox(
        height: 45,
        child: ElevatedButton(
          onPressed: _onApply,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Áp dụng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _onClear() {
    setState(() {
      _selectedTime = '';
      _selectedMeals.clear();
      _selectedCuisines.clear();
    });
  }

  void _onApply() {
    // Validation view is now informational; closes when user taps apply.
    Navigator.of(context, rootNavigator: true).pop();
  }

  String _buildSummaryText() {
    final parts = <String>[];
    if (_selectedTime.isNotEmpty) {
      switch (_selectedTime) {
        case 'under15':
          parts.add('Dưới 15 phút');
          break;
        case '15to30':
          parts.add('15–30 phút');
          break;
        case 'over30':
          parts.add('Trên 30 phút');
          break;
        default:
          parts.add('Không lọc thời gian');
      }
    }
    if (_selectedMeals.isNotEmpty) {
      parts.add('Bữa: ${_selectedMeals.join(', ')}');
    }
    if (_selectedCuisines.isNotEmpty) {
      parts.add('Ẩm thực: ${_selectedCuisines.join(', ')}');
    }
    return parts.isEmpty
        ? 'Chọn bộ lọc để tinh chỉnh gợi ý món ăn.'
        : parts.join(' • ');
  }
}
