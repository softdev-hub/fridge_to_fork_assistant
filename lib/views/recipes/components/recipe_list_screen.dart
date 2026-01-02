import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../controllers/recipe_suggestion_controller.dart';
import '../../../controllers/recipe_suggestion_filters.dart';
import '../../../models/enums.dart';
import '../../../models/recipe_ingredient.dart';
import 'recipe_card_list.dart';
import 'recipe_matching_filter_bar.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final RecipeSuggestionController _controller = RecipeSuggestionController();
  late Future<_RecipeScreenData> _future;
  RecipeFilterOptions _filters = const RecipeFilterOptions(
    timeKey: '',
    mealLabels: <String>{},
    cuisineLabels: <String>{},
    ingredientLabels: <String>{},
  );

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RecipeScreenData> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return _RecipeScreenData(recipes: const [], fullCount: 0, authRequired: true);
    }

    final suggestions = await _controller.getSuggestedRecipes(
      callAiAdvisor: false, // tránh phụ thuộc edge function khi demo
      seedIfEmpty: false, // dùng dữ liệu thật của user đang đăng nhập
      checkQuantity: false, // nới lỏng để vẫn hiển thị gần đủ khi thiếu lượng
    );
    final filtered = RecipeSuggestionFilters.applyToSuggestions(
      suggestions,
      _filters,
      lenientMissing: true,
    );
    final cards = filtered.map(_mapToCardModel).toList();
    final fullCount = cards.where((c) => c.matchType == MatchType.full).length;
    return _RecipeScreenData(recipes: cards, fullCount: fullCount);
  }

  RecipeCardModel _mapToCardModel(RecipeSuggestion suggestion) {
    final recipe = suggestion.recipe;
    final available =
        suggestion.match.availableIngredients ??
        suggestion.matchedIngredients.length;
    final total =
        suggestion.match.totalIngredients ??
        (suggestion.matchedIngredients.length +
            suggestion.missingIngredients.length);
    final missing =
        suggestion.match.missingIngredients ??
        suggestion.missingIngredients.length;

    RecipeDifficulty _diff(RecipeDifficultyEnum? d) {
      switch (d) {
        case RecipeDifficultyEnum.medium:
          return RecipeDifficulty.medium;
        case RecipeDifficultyEnum.hard:
          return RecipeDifficulty.hard;
        case RecipeDifficultyEnum.easy:
        case null:
          return RecipeDifficulty.easy;
      }
    }

    RecipeMealTime _meal(MealTypeEnum? m) {
      switch (m) {
        case MealTypeEnum.lunch:
          return RecipeMealTime.lunch;
        case MealTypeEnum.dinner:
          return RecipeMealTime.dinner;
        case MealTypeEnum.breakfast:
        case null:
          return RecipeMealTime.breakfast;
      }
    }

    String _timeLabel(int? minutes) {
      if (minutes == null || minutes <= 0) return 'Không rõ thời gian';
      return '$minutes phút';
    }

    String _ingredientName(RecipeIngredient ri) =>
        ri.ingredient?.name ?? 'Nguyên liệu #${ri.ingredientId}';

    final availableNames = suggestion.matchedIngredients
        .map(_ingredientName)
        .toList();
    final missingNames = suggestion.missingIngredients
        .map(_ingredientName)
        .toList();

    return RecipeCardModel(
      recipeId: recipe.recipeId,
      name: recipe.title,
      timeLabel: _timeLabel(recipe.cookingTimeMinutes),
      difficulty: _diff(recipe.difficulty),
      mealTime: _meal(recipe.mealType),
      matchType: missing <= 0 ? MatchType.full : MatchType.partial,
      availableIngredients: available,
      totalIngredients: total,
      missingCount: missing,
      expiringCount: 0,
      isExpiring: false,
      availableNames: availableNames,
      missingNames: missingNames,
      instructions: recipe.instructions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 768;
        final isDesktop = constraints.maxWidth >= 1024;
        final horizontalPadding = isTablet ? 32.0 : 24.0;

        return Container(
          color: const Color(0xFFF8F9FA),
          child: SafeArea(
            bottom: true,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                0,
              ),
              child: FutureBuilder<_RecipeScreenData>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _ErrorState(
                      message: 'Không tải được gợi ý: ${snapshot.error}',
                      onRetry: () {
                        setState(() {
                          _future = _load();
                        });
                      },
                    );
                  }

                  final data = snapshot.data;
                  final recipes = data?.recipes ?? [];

                  if (data?.authRequired == true) {
                    return const _AuthRequiredState();
                  }

                  if (recipes.isEmpty) {
                    return _EmptyState(
                      onRetry: () {
                        setState(() {
                          _future = _load();
                        });
                      },
                      onClearFilters: _clearFilters,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RecipeMatchingFilterBar(
                        filters: _filters,
                        onApplied: (options) {
                          setState(() {
                            _filters = options;
                            _future = _load();
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _SummaryRow(
                        total: recipes.length,
                        fullCount: data?.fullCount ?? 0,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              _future = _load();
                            });
                            await _future;
                          },
                          child: RecipeCardList(
                            recipes: recipes,
                            isTablet: isTablet,
                            isDesktop: isDesktop,
                            physics: const AlwaysScrollableScrollPhysics(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _filters = const RecipeFilterOptions(
        timeKey: '',
        mealLabels: <String>{},
        cuisineLabels: <String>{},
        ingredientLabels: <String>{},
      );
      _future = _load();
    });
  }

  void _clearIngredientFilter() {
    setState(() {
      _filters = RecipeFilterOptions(
        timeKey: _filters.timeKey,
        mealLabels: _filters.mealLabels,
        cuisineLabels: _filters.cuisineLabels,
        ingredientLabels: <String>{},
      );
      _future = _load();
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final int total;
  final int fullCount;

  const _SummaryRow({required this.total, required this.fullCount});

  @override
  Widget build(BuildContext context) {
    final flexCount = total - fullCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dùng kho hiện tại',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          'Tìm thấy $total (đủ $fullCount, gần đủ $flexCount)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback? onClearFilters;

  const _EmptyState({required this.onRetry, this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, color: Color(0xFF9CA3AF), size: 48),
          const SizedBox(height: 12),
          const Text(
            'Chưa có gợi ý phù hợp',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tải lại'),
              ),
              if (onClearFilters != null)
                ElevatedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Bỏ lọc'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeScreenData {
  final List<RecipeCardModel> recipes;
  final int fullCount;
  final bool authRequired;

  _RecipeScreenData({
    required this.recipes,
    required this.fullCount,
    this.authRequired = false,
  });
}

class _AuthRequiredState extends StatelessWidget {
  const _AuthRequiredState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.lock_outline, color: Color(0xFF9CA3AF), size: 48),
          SizedBox(height: 12),
          Text(
            'Bạn cần đăng nhập để xem gợi ý từ kho của mình.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
