// lib/recipes/components/recipe_filter_sheet.dart

import 'package:flutter/material.dart';

class RecipeFilterSheet extends StatefulWidget {
  final Function(Map<String, dynamic>)? onApply;
  final Function()? onClear;

  const RecipeFilterSheet({
    Key? key,
    this.onApply,
    this.onClear,
  }) : super(key: key);

  @override
  State<RecipeFilterSheet> createState() => _RecipeFilterSheetState();
}

class _RecipeFilterSheetState extends State<RecipeFilterSheet> {
  String _selectedTime = 'none';
  final Set<String> _selectedMeals = {'Trưa', 'Tối'};
  final Set<String> _selectedCuisines = {'Á', 'Chay'};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isTablet = maxWidth >= 768;
        final sheetMaxWidth = isTablet ? 500.0 : 412.0;

        return Container(
          width: maxWidth > sheetMaxWidth ? sheetMaxWidth : maxWidth,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      _buildFilterContent(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
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
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTimeSection(),
        const SizedBox(height: 24),
        _buildMealSection(),
        const SizedBox(height: 24),
        _buildCuisineSection(),
        const SizedBox(height: 24),
        _buildSummarySection(),
      ],
    );
  }

  Widget _buildTimeSection() {
    return _FilterSection(
      title: 'Thời gian nấu',
      child: Column(
        children: [
          _RadioOption(
            label: 'Không lọc',
            isSelected: _selectedTime == 'none',
            onTap: () => setState(() => _selectedTime = 'none'),
          ),
          const SizedBox(height: 8),
          _RadioOption(
            label: '≤ 15 phút',
            isSelected: _selectedTime == '15',
            onTap: () => setState(() => _selectedTime = '15'),
          ),
          const SizedBox(height: 8),
          _RadioOption(
            label: '15–30 phút',
            isSelected: _selectedTime == '30',
            onTap: () => setState(() => _selectedTime = '30'),
          ),
          const SizedBox(height: 8),
          _RadioOption(
            label: '> 30 phút',
            isSelected: _selectedTime == '30+',
            onTap: () => setState(() => _selectedTime = '30+'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection() {
    return _FilterSection(
      title: 'Loại bữa',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ChipOption(
            label: 'Sáng',
            isSelected: _selectedMeals.contains('Sáng'),
            onTap: () {
              setState(() {
                if (_selectedMeals.contains('Sáng')) {
                  _selectedMeals.remove('Sáng');
                } else {
                  _selectedMeals.add('Sáng');
                }
              });
            },
          ),
          _ChipOption(
            label: 'Trưa',
            isSelected: _selectedMeals.contains('Trưa'),
            onTap: () {
              setState(() {
                if (_selectedMeals.contains('Trưa')) {
                  _selectedMeals.remove('Trưa');
                } else {
                  _selectedMeals.add('Trưa');
                }
              });
            },
          ),
          _ChipOption(
            label: 'Tối',
            isSelected: _selectedMeals.contains('Tối'),
            onTap: () {
              setState(() {
                if (_selectedMeals.contains('Tối')) {
                  _selectedMeals.remove('Tối');
                } else {
                  _selectedMeals.add('Tối');
                }
              });
            },
          ),
          _ChipOption(
            label: 'Snack',
            isSelected: _selectedMeals.contains('Snack'),
            onTap: () {
              setState(() {
                if (_selectedMeals.contains('Snack')) {
                  _selectedMeals.remove('Snack');
                } else {
                  _selectedMeals.add('Snack');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineSection() {
    return _FilterSection(
      title: 'Ẩm thực',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ChipOption(
            label: 'Á',
            isSelected: _selectedCuisines.contains('Á'),
            onTap: () {
              setState(() {
                if (_selectedCuisines.contains('Á')) {
                  _selectedCuisines.remove('Á');
                } else {
                  _selectedCuisines.add('Á');
                }
              });
            },
          ),
          _ChipOption(
            label: 'Âu',
            isSelected: _selectedCuisines.contains('Âu'),
            onTap: () {
              setState(() {
                if (_selectedCuisines.contains('Âu')) {
                  _selectedCuisines.remove('Âu');
                } else {
                  _selectedCuisines.add('Âu');
                }
              });
            },
          ),
          _ChipOption(
            label: 'Mỹ',
            isSelected: _selectedCuisines.contains('Mỹ'),
            onTap: () {
              setState(() {
                if (_selectedCuisines.contains('Mỹ')) {
                  _selectedCuisines.remove('Mỹ');
                } else {
                  _selectedCuisines.add('Mỹ');
                }
              });
            },
          ),
          _ChipOption(
            label: 'Hàn',
            isSelected: _selectedCuisines.contains('Hàn'),
            onTap: () {
              setState(() {
                if (_selectedCuisines.contains('Hàn')) {
                  _selectedCuisines.remove('Hàn');
                } else {
                  _selectedCuisines.add('Hàn');
                }
              });
            },
          ),
          _ChipOption(
            label: 'Nhật',
            isSelected: _selectedCuisines.contains('Nhật'),
            onTap: () {
              setState(() {
                if (_selectedCuisines.contains('Nhật')) {
                  _selectedCuisines.remove('Nhật');
                } else {
                  _selectedCuisines.add('Nhật');
                }
              });
            },
          ),
          _ChipOption(
            label: 'Chay',
            isSelected: _selectedCuisines.contains('Chay'),
            onTap: () {
              setState(() {
                if (_selectedCuisines.contains('Chay')) {
                  _selectedCuisines.remove('Chay');
                } else {
                  _selectedCuisines.add('Chay');
                }
              });
            },
          ),
          _ChipOption(
            label: 'Khác',
            isSelected: _selectedCuisines.contains('Khác'),
            onTap: () {
              setState(() {
                if (_selectedCuisines.contains('Khác')) {
                  _selectedCuisines.remove('Khác');
                } else {
                  _selectedCuisines.add('Khác');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final timeText = _selectedTime == 'none'
        ? 'Không lọc thời gian'
        : _selectedTime == '15'
            ? '≤ 15 phút'
            : _selectedTime == '30'
                ? '15–30 phút'
                : '> 30 phút';

    final mealText = _selectedMeals.isEmpty
        ? ''
        : 'Bữa ${_selectedMeals.join(' và ')}';

    final cuisineText = _selectedCuisines.isEmpty
        ? ''
        : 'Ẩm thực ${_selectedCuisines.join(' và ')}';

    final summaryParts = [
      timeText,
      if (mealText.isNotEmpty) mealText,
      if (cuisineText.isNotEmpty) cuisineText,
    ].where((part) => part.isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đang áp dụng:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summaryParts.join(', ') + '.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4CAF50),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedTime = 'none';
                  _selectedMeals.clear();
                  _selectedCuisines.clear();
                });
                widget.onClear?.call();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                foregroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Xóa bộ lọc',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                final filters = {
                  'time': _selectedTime,
                  'meals': _selectedMeals.toList(),
                  'cuisines': _selectedCuisines.toList(),
                };
                widget.onApply?.call(filters);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChipOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

