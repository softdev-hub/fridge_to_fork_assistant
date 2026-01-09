import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../controllers/pantry_item_controller.dart';

/// Service để giao tiếp với AI API qua OpenRouter
/// Sử dụng model Meta Llama 3.2 (miễn phí)
class AiChatService {
  // Singleton instance
  static final AiChatService _instance = AiChatService._internal();
  factory AiChatService() => _instance;
  AiChatService._internal();

  final PantryItemController _pantryController = PantryItemController();
  final List<Map<String, String>> _chatHistory = [];

  // Lưu lịch sử tin nhắn để hiển thị trên UI (giữ nguyên khi quay lại ChatView)
  final List<Map<String, dynamic>> _displayMessages = [];

  /// Getter cho display messages
  List<Map<String, dynamic>> get displayMessages => _displayMessages;

  /// Thêm tin nhắn vào lịch sử hiển thị
  void addDisplayMessage({required String content, required bool isUser}) {
    _displayMessages.add({
      'content': content,
      'isUser': isUser,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Kiểm tra đã có lịch sử chat chưa
  bool get hasHistory => _displayMessages.isNotEmpty;
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // Model miễn phí từ OpenRouter (Meta Llama 3.2 3B - miễn phí)
  static const String _model = 'meta-llama/llama-3.2-3b-instruct:free';

  /// Khởi tạo service
  Future<void> initialize() async {
    await ensureEnvLoaded();

    if (openRouterApiKey.isEmpty) {
      throw Exception(
        'OpenRouter API Key chưa được cấu hình trong .env\n'
        'Vui lòng:\n'
        '1. Đăng ký tại https://openrouter.ai/\n'
        '2. Lấy API key từ https://openrouter.ai/keys\n'
        '3. Thêm OPENROUTER_API_KEY=... vào file .env',
      );
    }

    // Thêm system prompt vào history
    _chatHistory.clear();
  }

  /// System prompt mô tả vai trò của AI
  String get _systemPrompt => '''
Bạn là trợ lý nấu ăn thông minh của ứng dụng "Fridge to Fork Assistant" - ứng dụng quản lý tủ lạnh và gợi ý công thức nấu ăn.

Nhiệm vụ của bạn:
1. Gợi ý các món ăn dựa trên nguyên liệu có trong tủ lạnh của người dùng
2. Cung cấp công thức nấu ăn chi tiết khi được yêu cầu
3. Tư vấn về cách bảo quản thực phẩm, thời hạn sử dụng
4. Đề xuất thực đơn cân bằng dinh dưỡng
5. Trả lời các câu hỏi về ẩm thực Việt Nam và thế giới

Quy tắc:
- Luôn trả lời bằng tiếng Việt
- Ưu tiên gợi ý món ăn từ nguyên liệu đã có sẵn
- Công thức phải chi tiết, dễ hiểu
- Đưa ra lời khuyên thiết thực, phù hợp với bếp gia đình Việt Nam

Phong cách:
- Thân thiện, nhiệt tình như một đầu bếp gia đình
- Sử dụng emoji để làm câu trả lời sinh động hơn
- Ngắn gọn nhưng đầy đủ thông tin
''';

  /// Lấy danh sách nguyên liệu trong pantry để đưa vào context
  Future<String> _buildPantryContext() async {
    try {
      final items = await _pantryController.getAllPantryItems();

      if (items.isEmpty) {
        return 'Hiện tại tủ lạnh của người dùng đang trống.';
      }

      final buffer = StringBuffer();
      buffer.writeln('Danh sách nguyên liệu trong tủ lạnh của người dùng:');

      for (final item in items) {
        final name = item.ingredient?.name ?? 'Không rõ';
        final quantity = item.quantity;
        final unit = item.unit.displayName;
        final expiryInfo = item.expiryDate != null
            ? ' (HSD: ${_formatDate(item.expiryDate!)})'
            : '';

        buffer.writeln('- $name: $quantity $unit$expiryInfo');
      }

      return buffer.toString();
    } catch (e) {
      return 'Không thể lấy thông tin tủ lạnh.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Gửi tin nhắn và nhận phản hồi từ AI
  Future<String> sendMessage(String userMessage) async {
    try {
      // Kiểm tra xem người dùng hỏi về pantry/nguyên liệu
      final lowerMessage = userMessage.toLowerCase();
      final isPantryRelated =
          lowerMessage.contains('tủ lạnh') ||
          lowerMessage.contains('nguyên liệu') ||
          lowerMessage.contains('có gì') ||
          lowerMessage.contains('nấu gì') ||
          lowerMessage.contains('kho') ||
          lowerMessage.contains('pantry') ||
          lowerMessage.contains('trong nhà');

      String fullMessage = userMessage;

      // Nếu hỏi về nguyên liệu, inject context pantry
      if (isPantryRelated) {
        final pantryContext = await _buildPantryContext();
        fullMessage =
            '''
$pantryContext

Câu hỏi của người dùng: $userMessage
''';
      }

      // Thêm tin nhắn user vào history
      _chatHistory.add({'role': 'user', 'content': fullMessage});

      // Tạo request body
      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        ..._chatHistory,
      ];

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openRouterApiKey',
          'HTTP-Referer': 'https://fridge-to-fork.app',
          'X-Title': 'Fridge to Fork Assistant',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 2048,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;

        // Thêm response vào history
        _chatHistory.add({'role': 'assistant', 'content': aiResponse});

        return aiResponse;
      } else {
        final error = jsonDecode(response.body);
        return '❌ Lỗi API: ${error['error']?['message'] ?? response.body}';
      }
    } catch (e) {
      return '❌ Đã xảy ra lỗi: ${e.toString()}';
    }
  }

  /// Reset cuộc hội thoại
  void resetChat() {
    _chatHistory.clear();
    _displayMessages.clear();
  }

  /// Kiểm tra service đã được khởi tạo chưa
  bool get isInitialized => true;
}
