import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'components/recipe_card_list.dart';
import '../../models/recipe_ingredient.dart';
import '../../models/ingredient.dart';
import '../../models/enums.dart';
import '../../services/shared_recipe_service.dart';

class RecipeDetailView extends StatefulWidget {
  final RecipeCardModel recipe;
  final bool showAddToPlanButton;

  const RecipeDetailView({
    super.key,
    required this.recipe,
    this.showAddToPlanButton = true,
  });

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  List<RecipeIngredient> _missingIngredientEntities = [];
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isVideoLoading = false;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _loadMissingIngredients();
    _initVideo();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _loadMissingIngredients() async {
    // Sử dụng real missing ingredients từ database
    if (widget.recipe.missingNames.isNotEmpty) {
      _missingIngredientEntities = _createMissingIngredientsFromNames(
        widget.recipe.missingNames,
      );
      print(
        '📝 Sử dụng real missing ingredients: ${widget.recipe.missingNames}',
      );
    } else if (widget.recipe.missingCount != null &&
        widget.recipe.missingCount! > 0) {
      // Fallback: tạo dummy nếu không có real data
      _missingIngredientEntities = _createDummyMissingIngredients(
        widget.recipe.missingCount!,
      );
      print(
        '📝 Fallback: sử dụng dummy missing ingredients, count: ${widget.recipe.missingCount}',
      );
    }

    setState(() {});
  }

  Future<void> _initVideo() async {
    final url = widget.recipe.videoUrl?.trim();
    if (url == null || url.isEmpty) return;

    setState(() {
      _isVideoLoading = true;
      _videoError = null;
    });

    try {
      // YouTube (play embedded, not opening external app/browser)
      final ytId = YoutubePlayer.convertUrlToId(url);
      if (ytId != null && ytId.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: ytId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            enableCaption: true,
          ),
        );
        if (!mounted) return;
        setState(() {
          _isVideoLoading = false;
        });
        return;
      }

      // Non-YouTube (mp4/hls/stream url) via video_player + chewie
      final uri = Uri.tryParse(url);
      if (uri == null) {
        throw Exception('URL video không hợp lệ');
      }

      _videoPlayerController = VideoPlayerController.networkUrl(uri);
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        showControls: true,
        allowPlaybackSpeedChanging: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF4CAF50),
          handleColor: const Color(0xFF4CAF50),
          bufferedColor: const Color(0xFFE5E7EB),
          backgroundColor: const Color(0xFFCBD5E1),
        ),
      );

      if (!mounted) return;
      setState(() {
        _isVideoLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVideoLoading = false;
        _videoError = 'Không thể phát video: $e';
      });
    }
  }

  // Tạo missing ingredients từ tên thật (real data)
  List<RecipeIngredient> _createMissingIngredientsFromNames(
    List<String> names,
  ) {
    return List.generate(
      names.length,
      (index) => RecipeIngredient(
        recipeId: widget.recipe.recipeId ?? 0,
        ingredientId: index + 1000, // Use high ID to avoid conflicts
        quantity: 1.0,
        unit: UnitEnum.cai, // Default unit
        ingredient: Ingredient(
          ingredientId: index + 1000,
          name: names[index],
          category: 'missing',
        ),
      ),
    );
  }

  // Tạo dummy missing ingredients cho testing (fallback)
  List<RecipeIngredient> _createDummyMissingIngredients(int count) {
    final dummyIngredients = [
      'Hành tây',
      'Tỏi',
      'Gừng',
      'Ớt',
      'Nước mắm',
      'Đường',
      'Muối',
      'Tiêu',
      'Rau thơm',
      'Chanh',
    ];

    return List.generate(
      count,
      (index) => RecipeIngredient(
        recipeId: 0, // RecipeCardModel không có recipeId; dùng 0 cho dummy
        ingredientId: index + 1,
        quantity: 1.0 + index,
        unit: UnitEnum.g,
        ingredient: Ingredient(
          ingredientId: index + 1,
          name: dummyIngredients[index % dummyIngredients.length],
          category: 'spices',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableList = _availableIngredients();
    final missingList = _getMissingIngredientsDisplay();
    final instructionSteps = _instructionSteps();
    final bottomPadding =
        24 +
        MediaQuery.of(context).padding.bottom +
        (widget.showAddToPlanButton ? kBottomNavigationBarHeight : 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
        title: const Text(
          'Chi tiết công thức',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Không tải lại dữ liệu từ server ở màn chi tiết tĩnh; chỉ giả lập delay nhỏ.
          await Future<void>.delayed(const Duration(milliseconds: 200));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroImage(),
                    const SizedBox(height: 16),
                    Text(
                      widget.recipe.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _metaRow(context),
                    const SizedBox(height: 8),
                    _metaRow2(context),
                  ],
                ),
              ),

              // Ingredients summary
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nguyên liệu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ingredientGroup(
                      title: 'Bạn đã có',
                      titleColor: const Color(0xFF16A34A),
                      items: availableList.isNotEmpty
                          ? availableList
                          : ['Chưa có thông tin nguyên liệu sẵn có'],
                      icon: Icons.check_circle,
                      iconColor: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 16),
                    if (missingList.isNotEmpty)
                      _ingredientGroup(
                        title: 'Cần mua thêm',
                        titleColor: const Color(0xFFF59E0B),
                        items: missingList,
                        icon: Icons.add_circle,
                        iconColor: const Color(0xFFF59E0B),
                        showAddButton: true,
                      ),
                  ],
                ),
              ),

              // Video placeholder
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Video hướng dẫn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVideoPlayer(),
                  ],
                ),
              ),

              // Steps (static placeholders)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Các bước thực hiện',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (instructionSteps.isNotEmpty)
                      ...instructionSteps.asMap().entries.map(
                        (e) => _stepCard(e.key + 1, e.value),
                      )
                    else ...[
                      _stepCard(1, 'Chuẩn bị đầy đủ nguyên liệu.'),
                      _stepCard(2, 'Sơ chế và ướp theo khẩu vị.'),
                      _stepCard(3, 'Chế biến theo hướng dẫn và thưởng thức.'),
                    ],
                  ],
                ),
              ),

              // Actions
              if (widget.showAddToPlanButton)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.event, color: Colors.white),
                      label: const Text(
                        'Thêm món vào Kế hoạch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        // Đặt recipe vào shared service
                        SharedRecipeService().setSelectedRecipe(
                          widget.recipe,
                          fromTab: true,
                        );

                        // Yêu cầu HomeView chuyển sang tab Kế hoạch (index 3)
                        // và đóng màn chi tiết để tránh bị "thừa" bottom nav.
                        SharedRecipeService().requestOpenPlanRecipeSheet();
                        SharedRecipeService().requestSwitchTab(3);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroImage() {
    final imageUrl = widget.recipe.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 56,
                      color: Color(0xFF9CA3AF),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              )
            : const Center(
                child: Icon(Icons.image, size: 64, color: Color(0xFF9CA3AF)),
              ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final url = widget.recipe.videoUrl?.trim();

    if (url == null || url.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.ondemand_video, color: Color(0xFF6B7280)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Chưa có video hướng dẫn cho công thức này.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ),
          ],
        ),
      );
    }

    if (_isVideoLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_videoError != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          border: Border.all(color: const Color(0xFFFCD34D)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _videoError!,
                style: const TextStyle(fontSize: 14, color: Color(0xFFD97706)),
              ),
            ),
          ],
        ),
      );
    }

    if (_youtubeController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFF4CAF50),
        ),
      );
    }

    if (_chewieController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _videoPlayerController?.value.aspectRatio ?? (16 / 9),
          child: Chewie(controller: _chewieController!),
        ),
      );
    }

    // Fallback
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_fill, size: 64, color: Color(0xFF6B7280)),
      ),
    );
  }

  Widget _metaRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _metaItem(Icons.access_time, widget.recipe.timeLabel),
        _separator(),
        _metaItem(Icons.people_alt, '1 khẩu phần'),
        _separator(),
        _metaItem(Icons.restaurant_menu, _mealLabel()),
      ],
    );
  }

  Widget _metaRow2(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _metaItem(Icons.adjust, _difficultyLabel()),
        _separator(),
        _metaItem(Icons.public, _cuisineLabel()),
      ],
    );
  }

  Widget _metaItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _separator() =>
      const Text('·', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)));

  Widget _ingredientGroup({
    required String title,
    required Color titleColor,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
    bool showAddButton = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showAddButton) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 18, color: Color(0xFFD97706)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Thêm món vào Kế hoạch để thêm nguyên liệu thiếu vào Danh sách mua sắm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD97706),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _stepCard(int number, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _mealLabel() {
    switch (widget.recipe.mealTime) {
      case RecipeMealTime.breakfast:
        return 'Bữa sáng';
      case RecipeMealTime.lunch:
        return 'Bữa trưa';
      case RecipeMealTime.dinner:
        return 'Bữa tối';
    }
  }

  String _difficultyLabel() {
    switch (widget.recipe.difficulty) {
      case RecipeDifficulty.easy:
        return 'Dễ';
      case RecipeDifficulty.medium:
        return 'Trung bình';
      case RecipeDifficulty.hard:
        return 'Khó';
    }
  }

  String _cuisineLabel() {
    // Chưa có dữ liệu ẩm thực, tạm thời hiển thị cố định
    return 'Ẩm thực Á';
  }

  List<String> _availableIngredients() {
    if (widget.recipe.availableNames.isNotEmpty) {
      return widget.recipe.availableNames;
    }
    final count = widget.recipe.availableIngredients;
    if (count <= 0) return [];
    return List.generate(count, (i) => 'Nguyên liệu có sẵn #${i + 1}');
  }

  List<String> _missingIngredientNames() {
    if (widget.recipe.missingNames.isNotEmpty)
      return widget.recipe.missingNames;
    final inferredMissing =
        (widget.recipe.totalIngredients - widget.recipe.availableIngredients)
            .clamp(0, 99);
    final count = widget.recipe.missingCount ?? inferredMissing;
    if (count <= 0) return [];
    return List.generate(count, (i) => 'Nguyên liệu cần mua #${i + 1}');
  }

  List<String> _getMissingIngredientsDisplay() {
    if (_missingIngredientEntities.isNotEmpty) {
      return _missingIngredientEntities
          .map((e) => e.ingredient?.name ?? 'Nguyên liệu cần mua')
          .toList();
    }
    return _missingIngredientNames();
  }

  List<String> _instructionSteps() {
    final text = widget.recipe.instructions;
    if (text == null || text.trim().isEmpty) {
      return const [];
    }
    // Chuẩn hóa: thay literal "\n" thành xuống dòng thực.
    final normalized = text.replaceAll(r'\n', '\n');

    // Ưu tiên tách theo xuống dòng
    final lines = normalized
        .split(RegExp(r'[\r\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (lines.length > 1) {
      return lines
          .asMap()
          .entries
          .map((e) => _cleanStepText(e.value, e.key))
          .toList();
    }

    // Nếu chỉ còn một chuỗi, thử tách theo pattern "Bước x:"
    final stepPattern = RegExp(r'(?=Bước\s*\d+[:.\-])', caseSensitive: false);
    final viaStepKeyword = normalized
        .split(stepPattern)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (viaStepKeyword.length > 1) {
      return viaStepKeyword
          .asMap()
          .entries
          .map((e) => _cleanStepText(e.value, e.key))
          .toList();
    }

    // Nếu không có xuống dòng, tách theo dấu câu.
    final sentences = normalized
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return sentences
        .asMap()
        .entries
        .map((e) => _cleanStepText(e.value, e.key))
        .toList();
  }

  String _cleanStepText(String raw, int index) {
    // Loại bỏ tiền tố "Bước x:" nếu có, giữ phần nội dung.
    final cleaned = raw.replaceFirst(
      RegExp(r'^Bước\s*\d+\s*[:.-]?\s*', caseSensitive: false),
      '',
    );
    if (cleaned.trim().isNotEmpty) return cleaned.trim();
    // fallback: nếu sau khi cắt trống, dùng raw
    return raw.trim().isEmpty ? 'Bước ${index + 1}' : raw.trim();
  }
}
