import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'components/recipe_matching_filter_bar.dart';
import 'components/recipe_card_list.dart';
import 'components/recipe_fab.dart';
import '../common/bottomNavigation.dart';
import '../home_view.dart';
import '../pantry/pantry_view.dart';
import '../plans/plan_view.dart';
import '../../controllers/recipe_suggestion_controller.dart';
import '../../models/enums.dart';
import '../../models/recipe_ingredient.dart';

class RecipeMatchingView extends StatefulWidget {
  const RecipeMatchingView({Key? key}) : super(key: key);

  @override
  State<RecipeMatchingView> createState() => _RecipeMatchingViewState();
}

class _RecipeMatchingViewState extends State<RecipeMatchingView> {
  final RecipeSuggestionController _controller = RecipeSuggestionController();
  late Future<_MatchData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_MatchData> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const _MatchData(cards: <RecipeCardModel>[], authRequired: true);
    }

    final suggestions = await _controller.getSuggestedRecipes(
      callAiAdvisor: false,
      seedIfEmpty: false, // dùng dữ liệu thật của user đang đăng nhập
      checkQuantity: false, // nới lỏng để vẫn có gợi ý khi thiếu lượng
    );
    final cards = suggestions.map(_mapToCardModel).toList();
    return _MatchData(cards: cards);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Color(0xFF1F2937),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Gợi ý hôm nay',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 24,
                        color: Color(0xFF6B7280),
                      ),
                      onPressed: () {
                        // TODO: open settings
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: RecipeMatchingFilterBar(
                      selectedFilters: const ['time', 'meal', 'cuisine'],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<_MatchData>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
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
                        if (data == null) {
                          return _EmptyState(
                            onRetry: () {
                              setState(() {
                                _future = _load();
                              });
                            },
                          );
                        }

                        if (data.authRequired) {
                          return const _AuthRequiredState();
                        }

                        final recipes = data.cards;
                        if (recipes.isEmpty) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                _future = _load();
                              });
                              await _future;
                            },
                            child: ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              children: [
                                _EmptyState(
                                  onRetry: () {
                                    setState(() {
                                      _future = _load();
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              _future = _load();
                            });
                            await _future;
                          },
                          child: RecipeCardList(
                            recipes: recipes,
                            isTablet: false,
                            isDesktop: false,
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(right: 24, bottom: 24, child: RecipeFAB()),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 2) return;

    Widget? target;
    switch (index) {
      case 0:
        target = const HomeView();
        break;
      case 1:
        target = const PantryView();
        break;
      case 3:
        target = const PlanView();
        break;
    }

    if (target != null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => target!));
    }
  }
}

class _MatchData {
  final List<RecipeCardModel> cards;
  final bool authRequired;
  const _MatchData({required this.cards, this.authRequired = false});
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

  const _EmptyState({required this.onRetry});

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
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
          ),
        ],
      ),
    );
  }
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
