import 'package:flutter/material.dart';
import '../../../services/recipe_service.dart';
import 'plan_models.dart';
import '../../../services/shared_recipe_service.dart';

const String _fallbackImage =
    'https://images.unsplash.com/photo-1548943487-a2e4e43b4858?w=400';

class DraggableBottomSheet extends StatefulWidget {
  const DraggableBottomSheet({Key? key, required this.scrollController})
    : super(key: key);

  final ScrollController scrollController;

  @override
  State<DraggableBottomSheet> createState() => _RecipeAddFormState();
}

class _RecipeAddFormState extends State<DraggableBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Meal> _allMeals = [];
  List<Meal> _filteredMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _searchController.addListener(_applySearch);
  }

  Future<void> _loadRecipes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await RecipeService.instance.loadRecipeCards(
        filters: SharedRecipeService().lastAppliedFilters,
      );

      final meals = cards
          .where((c) => c.recipeId != null)
          .map(
            (c) => Meal(
              recipeId: c.recipeId,
              name: c.name,
              imageUrl: _fallbackImage,
            ),
          )
          .toList();

      // Nếu có recipe được chọn từ Recipes tab, đặt nó lên đầu (nhưng vẫn dùng
      // cùng data source để load list).
      final selectedRecipe = SharedRecipeService().selectedRecipe;
      List<Meal> ordered = meals;
      if (selectedRecipe != null && SharedRecipeService().isRecipeFromTab) {
        final selectedMeal = SharedRecipeService().recipeToMeal(selectedRecipe);
        ordered = [
          selectedMeal,
          ...meals.where((m) => m.recipeId != selectedMeal.recipeId),
        ];
      }

      if (!mounted) return;
      setState(() {
        _allMeals = ordered;
        _isLoading = false;
      });

      _applySearch();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _allMeals = const [];
        _filteredMeals = const [];
        _isLoading = false;
      });
    }
  }

  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();
    if (!mounted) return;
    setState(() {
      if (q.isEmpty) {
        _filteredMeals = List<Meal>.from(_allMeals);
      } else {
        _filteredMeals = _allMeals
            .where((m) => m.name.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        margin: EdgeInsets.zero,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm món, 15 phút, gà...',
                    hintStyle: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                    suffixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFilterButton(Icons.schedule, 'Thời gian'),
                  const SizedBox(width: 8),
                  _buildFilterButton(Icons.restaurant, 'Sữa'),
                  const SizedBox(width: 8),
                  _buildFilterButton(Icons.public, 'Ẩm thực'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Giữ công thức để kéo vào lịch',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 12),
              // Danh sách công thức kéo thả (từ SharedRecipeService)
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_filteredMeals.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      'Không có công thức để hiển thị',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ),
                )
              else
                Column(
                  children: List.generate(_filteredMeals.length, (index) {
                    final meal = _filteredMeals[index];
                    return Column(
                      children: [
                        _buildRecipeCard(
                          meal,
                          isHighlighted:
                              index == 0 &&
                              SharedRecipeService().isRecipeFromTab,
                        ),
                        if (index < _filteredMeals.length - 1)
                          const SizedBox(height: 12),
                      ],
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Meal meal, {bool isHighlighted = false}) {
    return LongPressDraggable<Meal>(
      data: meal,
      feedback: _buildCompressedCard(meal),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildFullCard(meal, isHighlighted: isHighlighted),
      ),
      child: _buildFullCard(meal, isHighlighted: isHighlighted),
    );
  }

  Widget _buildFullCard(Meal meal, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFFE8F5E9) // Màu xanh nhạt để highlight
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? Border.all(color: const Color(0xFF4CAF50), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                meal.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.restaurant,
                    color: Color(0xFF94A3B8),
                    size: 30,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (isHighlighted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Đã chọn',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildTag(
                      Icons.schedule,
                      '20 phút',
                      const Color(0xFF64748B),
                    ),
                    _buildTag(
                      Icons.bolt,
                      'Trung bình',
                      const Color(0xFF3730A3),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildStatusTag('Bữa sáng', const Color(0xFFFB923C)),
                    _buildStatusTag(
                      'Có 5/6 nguyên liệu',
                      const Color(0xFF15803D),
                    ),
                    _buildStatusTag(
                      'Thiếu 1 nguyên liệu',
                      const Color(0xFFB45309),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card thu nhỏ hiển thị khi đang kéo (nén lại).
  Widget _buildCompressedCard(Meal meal) {
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: 0.8,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  meal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
