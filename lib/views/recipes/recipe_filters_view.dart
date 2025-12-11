import 'dart:ui';
import 'package:flutter/material.dart';
import 'components/recipe_filter_sheet.dart';

class RecipeFiltersView extends StatelessWidget {
  const RecipeFiltersView({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const RecipeFiltersView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Blurred background content
            _buildBlurredBackground(context),
            // Bottom sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - value) * MediaQuery.of(context).size.height),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: RecipeFilterSheet(
                  onApply: (filters) {
                    // TODO: Apply filters
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Áp dụng bộ lọc thành công!'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                  onClear: () {
                    // TODO: Clear filters
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa tất cả bộ lọc'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlurredBackground(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            color: Colors.transparent,
            child: SafeArea(
              child: Column(
                children: [
                  _buildBlurredAppBar(),
                  Expanded(
                    child: _buildBlurredContent(),
                  ),
                  _buildBlurredBottomNav(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlurredAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: 0.1,
            child: const Text(
              'Gợi ý món',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Opacity(
            opacity: 0.1,
            child: IconButton(
              icon: const Icon(
                Icons.person,
                size: 24,
                color: Color(0xFF6B7280),
              ),
              onPressed: null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredContent() {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.1,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Opacity(
            opacity: 0.1,
            child: Container(
              height: 20,
              width: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Opacity(
            opacity: 0.1,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: 0.1,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredBottomNav() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        height: 57,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.home, size: 24, color: Color(0xFF6B7280)),
                  const SizedBox(height: 4),
                  const Text(
                    'Trang chủ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inventory, size: 24, color: Color(0xFF6B7280)),
                  const SizedBox(height: 4),
                  const Text(
                    'Kho',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restaurant_menu, size: 24, color: Color(0xFF4CAF50)),
                  const SizedBox(height: 4),
                  const Text(
                    'Công thức',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_note, size: 24, color: Color(0xFF6B7280)),
                  const SizedBox(height: 4),
                  const Text(
                    'Kế hoạch',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

