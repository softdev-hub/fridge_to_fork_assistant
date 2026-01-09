import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/services/auth_service.dart';
import 'package:fridge_to_fork_assistant/views/common/bottomNavigation.dart';
import 'package:fridge_to_fork_assistant/views/auth/profile_view.dart';
import 'package:fridge_to_fork_assistant/views/pantry/pantry_view.dart';
import 'package:fridge_to_fork_assistant/views/recipes/recipe_view.dart';
import 'package:fridge_to_fork_assistant/views/recipes/recipe_matching_view.dart';
import 'package:fridge_to_fork_assistant/views/plans/plan_view.dart';
import 'package:fridge_to_fork_assistant/views/notification/notification.dart';
import 'package:fridge_to_fork_assistant/views/auth/login_view.dart';
import 'package:fridge_to_fork_assistant/views/chat/chat_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/pantry_item.dart';
import '../models/recipe.dart';
import '../models/user_recipe_matches.dart';
import '../controllers/pantry_item_controller.dart';
import '../controllers/recipe_suggestion_controller.dart';
import '../utils/date_utils.dart' as app_date_utils;

class HomeView extends StatefulWidget {
  final int initialIndex;
  const HomeView({super.key, this.initialIndex = 0});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final authService = AuthService();
  late int _selectedIndex;
  final GlobalKey<PlanViewState> _planViewKey = GlobalKey<PlanViewState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void logout() async {
    await authService.signOut();
  }

  void _switchTab(int index) {
    setState(() => _selectedIndex = index);
    if (index == 3) {
      _planViewKey.currentState?.forceRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeContent(onTabChange: _switchTab),
      const PantryView(),
      const RecipeTabNavigator(),
      PlanView(key: _planViewKey),
      const RecipeMatchingView(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _switchTab,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatView()),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final void Function(int) onTabChange;

  const _HomeContent({required this.onTabChange});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final _supabase = Supabase.instance.client;
  final _pantryController = PantryItemController();

  Profile? _profile;
  List<PantryItem> _expiringItems = [];
  List<Map<String, dynamic>> _todayMeals = []; // Meal plans for today
  List<RecipeSuggestion> _suggestedRecipes = []; // Recipe suggestions
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        // Load profile
        final profileData = await _supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (profileData != null) {
          _profile = Profile.fromJson(profileData);
        }

        // Load today's meal plans
        await _loadTodayMeals(userId);

        // Load recipe suggestions
        await _loadRecipeSuggestions();
      }

      // Load expiring items
      final items = await _pantryController.getExpiringItems(days: 7);
      final notExpiredItems = items.where((item) => !item.isExpired).toList();
      notExpiredItems.sort((a, b) {
        if (a.expiryDate == null && b.expiryDate == null) return 0;
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return a.expiryDate!.compareTo(b.expiryDate!);
      });

      setState(() {
        _expiringItems = notExpiredItems.take(4).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTodayMeals(String userId) async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Get meal plans for today
      final mealPlansResponse = await _supabase
          .from('meal_plans')
          .select('meal_plan_id, meal_type')
          .eq('profile_id', userId)
          .eq('planned_date', dateStr);

      final mealPlans = mealPlansResponse as List;
      final List<Map<String, dynamic>> meals = [];

      for (final plan in mealPlans) {
        final mealPlanId = plan['meal_plan_id'];
        final mealType = plan['meal_type'] as String;

        // Get recipes for this meal plan
        final recipesResponse = await _supabase
            .from('meal_plan_recipes')
            .select('recipe_id, recipes(recipe_id, title, image_url)')
            .eq('meal_plan_id', mealPlanId);

        for (final recipeData in recipesResponse) {
          final recipe = recipeData['recipes'];
          if (recipe != null) {
            meals.add({
              'mealType': mealType,
              'title': recipe['title'],
              'imageUrl': recipe['image_url'],
              'recipeId': recipe['recipe_id'],
            });
          }
        }
      }

      _todayMeals = meals;
    } catch (e) {
      print('Error loading today meals: $e');
      _todayMeals = [];
    }
  }

  Future<void> _loadRecipeSuggestions() async {
    try {
      final controller = RecipeSuggestionController();
      final suggestions = await controller.getSuggestedRecipes(
        callAiAdvisor: false,
        seedIfEmpty: false,
        checkQuantity: false,
        autoGenerateFromPantry: true,
        maxMissingForFlexible: 10, // Rộng rãi hơn
        minCoverageForFlexible: 0.0,
      );
      print('🍳 Recipe suggestions loaded: ${suggestions.length}');

      if (suggestions.isNotEmpty) {
        _suggestedRecipes = suggestions.take(2).toList();
      } else {
        // Fallback: Lấy trực tiếp recipes từ database nếu không có gợi ý
        await _loadFallbackRecipes();
      }
    } catch (e) {
      print('Error loading recipe suggestions: $e');
      // Try fallback
      await _loadFallbackRecipes();
    }
  }

  Future<void> _loadFallbackRecipes() async {
    try {
      // Lấy trực tiếp các công thức từ database
      final recipesResponse = await _supabase
          .from('recipes')
          .select('*, recipe_ingredients(*, ingredients(*))')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(2);

      final List<RecipeSuggestion> fallbackSuggestions = [];
      for (final recipeJson in recipesResponse) {
        final recipe = Recipe.fromJson(recipeJson);
        if (recipe.recipeId == null) continue;

        fallbackSuggestions.add(
          RecipeSuggestion(
            recipe: recipe,
            match: UserRecipeMatch(
              profileId: _supabase.auth.currentUser?.id ?? '',
              recipeId: recipe.recipeId!,
              totalIngredients: recipe.ingredients?.length ?? 0,
              availableIngredients: 0,
              missingIngredients: recipe.ingredients?.length ?? 0,
            ),
            matchedIngredients: [],
            missingIngredients: recipe.ingredients ?? [],
            coverage: 0.0,
          ),
        );
      }

      print('🍳 Fallback recipes loaded: ${fallbackSuggestions.length}');
      _suggestedRecipes = fallbackSuggestions;
    } catch (e) {
      print('Error loading fallback recipes: $e');
      _suggestedRecipes = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8FAF7),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              )
            : RefreshIndicator(
                color: const Color(0xFF4CAF50),
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isDark),
                      const SizedBox(height: 24),
                      _buildExpiringIngredients(isDark),
                      const SizedBox(height: 24),
                      _buildPlanSection(isDark),
                      const SizedBox(height: 24),
                      _buildRecommendations(isDark),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final greeting = app_date_utils.DateUtils.getGreeting();
    final name = _profile?.name;
    final greetingText = name != null ? '$greeting, $name' : '$greeting.';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // Avatar button
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'profile') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  } else if (value == 'logout') {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        const Text('Hồ sơ'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red[400]),
                        const SizedBox(width: 12),
                        Text(
                          'Đăng xuất',
                          style: TextStyle(color: Colors.red[400]),
                        ),
                      ],
                    ),
                  ),
                ],
                offset: const Offset(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildAvatar(isDark),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  greetingText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[100] : Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 24,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF5C2D00) : const Color(0xFFFFF3E0),
        shape: BoxShape.circle,
      ),
      child: _profile?.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                _profile!.avatarUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  color: isDark ? Colors.orange[300] : Colors.orange[400],
                  size: 28,
                ),
              ),
            )
          : Icon(
              Icons.person,
              color: isDark ? Colors.orange[300] : Colors.orange[400],
              size: 28,
            ),
    );
  }

  Widget _buildExpiringIngredients(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D1212) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[500], size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Nguyên liệu sắp hết hạn',
                    style: TextStyle(
                      color: Colors.red[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  widget.onTabChange(1); // Switch to PantryView tab
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_expiringItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.green[900]!.withAlpha(80)
                    : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Không có nguyên liệu nào sắp hết hạn!',
                    style: TextStyle(color: Colors.green[700], fontSize: 13),
                  ),
                ],
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.0, // Giảm từ 2.15 để fix overflow
              children: _expiringItems.map((item) {
                final daysLeft = app_date_utils.DateUtils.daysUntil(
                  item.expiryDate,
                );
                return _buildIngredientCard(item, daysLeft, isDark);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(PantryItem item, int? daysLeft, bool isDark) {
    String daysText = '';
    Color textColor = Colors.orange[500]!;

    if (daysLeft != null) {
      if (daysLeft < 0) {
        daysText = 'Đã hết hạn';
        textColor = Colors.red[500]!;
      } else if (daysLeft == 0) {
        daysText = 'Hết hạn hôm nay';
        textColor = Colors.red[500]!;
      } else if (daysLeft == 1) {
        daysText = 'Còn 1 ngày';
        textColor = Colors.red[500]!;
      } else {
        daysText = 'Còn $daysLeft ngày';
        textColor = Colors.orange[500]!;
      }
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildPlaceholderImage(isDark),
                  )
                : _buildPlaceholderImage(isDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.ingredient?.name ?? 'Nguyên liệu',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? Colors.grey[100] : Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  daysText,
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, color: Colors.grey[400], size: 24),
    );
  }

  Widget _buildPlanSection(bool isDark) {
    // Get meal type label based on meal type from database
    String getMealTypeLabelFromType(String? mealType) {
      switch (mealType) {
        case 'breakfast':
          return 'Bữa sáng';
        case 'lunch':
          return 'Bữa trưa';
        case 'dinner':
          return 'Bữa tối';
        default:
          return 'Bữa ăn';
      }
    }

    // Get current meal type based on time
    String getCurrentMealType() {
      final hour = DateTime.now().hour;
      if (hour < 10) return 'breakfast';
      if (hour < 14) return 'lunch';
      return 'dinner';
    }

    // Find the next meal for today
    final currentMealType = getCurrentMealType();
    Map<String, dynamic>? nextMeal;

    // Priority: current meal type, then later meals
    for (final meal in _todayMeals) {
      if (meal['mealType'] == currentMealType) {
        nextMeal = meal;
        break;
      }
    }
    // If no current meal, get any meal for today
    if (nextMeal == null && _todayMeals.isNotEmpty) {
      nextMeal = _todayMeals.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kế hoạch của bạn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[100] : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (nextMeal != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getMealTypeLabelFromType(nextMeal['mealType']),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextMeal['title'] ?? 'Công thức',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark
                                  ? Colors.grey[100]
                                  : Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: nextMeal['imageUrl'] != null
                          ? Image.network(
                              nextMeal['imageUrl'],
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[200],
                                child: Icon(
                                  Icons.restaurant,
                                  color: Colors.grey[400],
                                ),
                              ),
                            )
                          : Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  ],
                ),
              ] else ...[
                // No meals planned for today
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chưa có kế hoạch cho hôm nay',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bữa ăn hôm nay',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _todayMeals.isEmpty
                              ? 'Chưa có món nào'
                              : 'Có ${_todayMeals.length} món đã lên kế hoạch',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[100] : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.restaurant_menu,
                      color: const Color(0xFF4CAF50),
                      size: 28,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onTabChange(3); // Switch to PlanView tab
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF1B4D1C)
                        : const Color(0xFFE8F5E9).withAlpha(180),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hôm nay ăn gì?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[100] : Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                widget.onTabChange(2); // Switch to RecipeView tab
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Show dynamic recipe suggestions or fallback message
        if (_suggestedRecipes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Thêm nguyên liệu vào tủ lạnh để nhận gợi ý công thức!',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ..._suggestedRecipes.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            final recipe = suggestion.recipe;
            final available = suggestion.matchedIngredients.length;
            final total = available + suggestion.missingIngredients.length;
            final timeLabel = recipe.cookingTimeMinutes != null
                ? '${recipe.cookingTimeMinutes} phút'
                : 'Không rõ';
            final ingredientLabel = 'Có $available/$total nguyên liệu';

            return Column(
              children: [
                if (index > 0) const SizedBox(height: 16),
                _buildRecipeCard(
                  recipe.title,
                  timeLabel,
                  ingredientLabel,
                  recipe.imageUrl ?? 'https://via.placeholder.com/400x200',
                  isDark,
                ),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildRecipeCard(
    String title,
    String time,
    String avail,
    String imageUrl,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.grey[100] : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      avail,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        fontSize: 13,
                      ),
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
}

/// Nested navigator for the “Công thức” tab so we can push recipe-related
/// screens without losing the bottom navigation from HomeView.
class RecipeTabNavigator extends StatelessWidget {
  const RecipeTabNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/matching':
            return MaterialPageRoute(
              builder: (_) => const RecipeMatchingView(),
              settings: settings,
            );
          case '/':
          default:
            return MaterialPageRoute(
              builder: (_) => const RecipeView(),
              settings: settings,
            );
        }
      },
    );
  }
}
