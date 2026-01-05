import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../controllers/recipe_suggestion_filters.dart';
import '../../../services/recipe_service.dart';
import '../../../services/shared_recipe_service.dart';
import 'recipe_card_list.dart';
import 'recipe_matching_filter_bar.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<_RecipeScreenData> _future;
  RecipeFilterOptions _filters = const RecipeFilterOptions(
    timeKey: '',
    mealLabels: <String>{},
    cuisineLabels: <String>{},
  );

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RecipeScreenData> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return _RecipeScreenData(
        recipes: const [],
        fullCount: 0,
        authRequired: true,
      );
    }

    final cards = await RecipeService.instance.loadRecipeCards(
      filters: _filters,
    );
    final fullCount = cards.where((c) => c.matchType == MatchType.full).length;

    // Cập nhật available recipes trong SharedRecipeService
    SharedRecipeService().setLastAppliedFilters(_filters);
    SharedRecipeService().updateAvailableRecipes(cards);

    return _RecipeScreenData(recipes: cards, fullCount: fullCount);
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

                  // Cập nhật available recipes trong SharedRecipeService
                  if (recipes.isNotEmpty) {
                    print(
                      '🔄 Cập nhật ${recipes.length} recipes vào SharedRecipeService',
                    );
                    for (var recipe in recipes) {
                      print(
                        '   Recipe: ${recipe.name}, Missing: ${recipe.missingNames}',
                      );
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      SharedRecipeService().setLastAppliedFilters(_filters);
                      SharedRecipeService().updateAvailableRecipes(recipes);
                    });
                  } else {
                    print('⚠️ Không có recipes để cập nhật');
                  }

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
