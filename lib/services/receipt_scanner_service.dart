import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/scanned_receipt_item.dart';
import '../models/enums.dart';

/// Service for scanning receipts using OCR and extracting product information
class ReceiptScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Scan an image file and extract list of products
  Future<List<ScannedReceiptItem>> scanReceipt(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      return _parseReceiptText(recognizedText.text);
    } catch (e) {
      throw Exception('Lỗi khi quét hóa đơn: $e');
    }
  }

  /// Parse raw OCR text into list of receipt items
  List<ScannedReceiptItem> _parseReceiptText(String rawText) {
    final List<ScannedReceiptItem> items = [];
    final lines = rawText.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final item = _parseLine(line, i < lines.length - 1 ? lines[i + 1] : null);
      if (item != null) {
        items.add(item);
      }
    }

    return items;
  }

  /// Parse a single line into a receipt item
  /// Vietnamese receipt formats:
  /// - "BÍ XANH 1.77 55,000 97,350"
  /// - "CHANH (KG) 1.478 40,000 59,120"
  /// - "BÍ ĐỎ HỒ LÔ (KG)\n2.518 50,000 125,900" (multi-line)
  ScannedReceiptItem? _parseLine(String line, String? nextLine) {
    // Skip header/footer lines
    if (_isHeaderOrFooter(line)) return null;

    // Pattern: Name followed by numbers (quantity, price, total)
    // Try to match product pattern
    final productMatch = _extractProductInfo(line, nextLine);
    if (productMatch != null) {
      return productMatch;
    }

    return null;
  }

  /// Check if line is header/footer (not a product)
  bool _isHeaderOrFooter(String line) {
    final lowerLine = line.toLowerCase();
    final skipPatterns = [
      'phiếu thanh toán',
      'hóa đơn',
      'thanh toán',
      'tổng tiền',
      'tiền mặt',
      'tiền thối',
      'nhân viên',
      'ngày ct',
      'số ct',
      'www.',
      'http',
      'địa chỉ',
      'điện thoại',
      'hotline',
      'gtgt',
      'vat',
      'bách hóa xanh',
      'co.op',
      'vinmart',
      'big c',
      'lotte',
      'sl',
      'giá bán',
      't.tiền',
      'đã làm tròn',
      'khiếu nại',
      'quý khách',
    ];

    for (final pattern in skipPatterns) {
      if (lowerLine.contains(pattern)) return true;
    }

    // Skip if line is just numbers (like date, receipt number)
    if (RegExp(r'^[\d\s/:,-]+$').hasMatch(line)) return true;

    return false;
  }

  /// Extract product information from line(s)
  ScannedReceiptItem? _extractProductInfo(String line, String? nextLine) {
    // Pattern 1: All on one line
    // "BÍ XANH 1.77 55,000 97,350"
    final singleLinePattern = RegExp(
      r'^([A-ZÀ-Ỹa-zà-ỹ\s\(\)]+?)\s+(\d+[.,]?\d*)\s+(\d{1,3}(?:[.,]\d{3})*)\s+(\d{1,3}(?:[.,]\d{3})*)$',
      caseSensitive: false,
    );

    var match = singleLinePattern.firstMatch(line);
    if (match != null) {
      return _createItemFromMatch(
        match.group(1)!,
        match.group(2)!,
        match.group(3),
        match.group(4),
      );
    }

    // Pattern 2: Name with unit indicator, numbers on next line
    // "CHANH (KG)" + "1.478 40,000 59,120"
    if (nextLine != null && _looksLikeProductName(line)) {
      final numbersPattern = RegExp(
        r'^(\d+[.,]?\d*)\s+(\d{1,3}(?:[.,]\d{3})*)\s+(\d{1,3}(?:[.,]\d{3})*)$',
      );
      final numbersMatch = numbersPattern.firstMatch(nextLine.trim());
      if (numbersMatch != null) {
        return _createItemFromMatch(
          line,
          numbersMatch.group(1)!,
          numbersMatch.group(2),
          numbersMatch.group(3),
        );
      }
    }

    // Pattern 3: Just name and quantity on same line
    // "BÍ XANH 1.77"
    final simplePattern = RegExp(
      r'^([A-ZÀ-Ỹa-zà-ỹ\s\(\)]+?)\s+(\d+[.,]?\d*)$',
      caseSensitive: false,
    );
    match = simplePattern.firstMatch(line);
    if (match != null && _looksLikeProductName(match.group(1)!)) {
      return _createItemFromMatch(match.group(1)!, match.group(2)!, null, null);
    }

    return null;
  }

  /// Check if text looks like a product name
  bool _looksLikeProductName(String text) {
    final cleaned = text.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
    // Must have at least 2 characters and contain letters
    return cleaned.length >= 2 && RegExp(r'[A-ZÀ-Ỹa-zà-ỹ]').hasMatch(cleaned);
  }

  /// Create ScannedReceiptItem from extracted data
  ScannedReceiptItem? _createItemFromMatch(
    String rawName,
    String quantityStr,
    String? unitPriceStr,
    String? totalPriceStr,
  ) {
    // Normalize name
    final name = _normalizeProductName(rawName);
    if (name.isEmpty) return null;

    // Parse quantity
    final quantity = _parseNumber(quantityStr);
    if (quantity == null || quantity <= 0) return null;

    // Detect unit from name
    final (adjustedQuantity, unit) = _detectAndConvertUnit(rawName, quantity);

    // Parse prices
    final unitPrice = unitPriceStr != null ? _parsePrice(unitPriceStr) : null;
    final totalPrice = totalPriceStr != null ? _parsePrice(totalPriceStr) : null;

    return ScannedReceiptItem(
      name: name,
      quantity: adjustedQuantity,
      unit: unit,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }

  /// Normalize product name
  /// "BÍ ĐỎ HỒ LÔ (KG)" → "Bí đỏ hồ lô"
  String _normalizeProductName(String rawName) {
    // Remove unit indicators
    var name = rawName
        .replaceAll(RegExp(r'\(KG\)|\(G\)|\(ML\)|\(L\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bKG\b|\bG\b', caseSensitive: false), '')
        .trim();

    // Remove special characters
    name = name.replaceAll(RegExp(r'[_\-]+'), ' ');

    // Title case
    if (name.isNotEmpty) {
      name = name
          .split(' ')
          .where((word) => word.isNotEmpty)
          .map((word) =>
              word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
    }

    return name;
  }

  /// Detect unit from product name and convert quantity if needed
  (double, UnitEnum) _detectAndConvertUnit(String rawName, double quantity) {
    final upperName = rawName.toUpperCase();

    // Check for KG indicator
    if (upperName.contains('(KG)') || upperName.contains(' KG')) {
      // Convert kg to g (multiply by 1000)
      return (quantity * 1000, UnitEnum.g);
    }

    // Check for ML/L indicator
    if (upperName.contains('(ML)') || upperName.contains(' ML')) {
      return (quantity, UnitEnum.ml);
    }
    if (upperName.contains('(L)') || upperName.contains(' L ')) {
      return (quantity * 1000, UnitEnum.ml);
    }

    // Check for piece indicators
    if (upperName.contains('(CÁI)') || upperName.contains('(TRÁI)')) {
      return (quantity, UnitEnum.cai);
    }
    if (upperName.contains('(QUẢ)') || upperName.contains('(TRÁI)')) {
      return (quantity, UnitEnum.qua);
    }

    // Default: if quantity is small (< 10), assume kg → g
    // Vietnamese supermarkets usually measure in kg for produce
    if (quantity < 10) {
      return (quantity * 1000, UnitEnum.g);
    }

    return (quantity, UnitEnum.g);
  }

  /// Parse number string (handles both . and , as decimal separator)
  double? _parseNumber(String str) {
    try {
      // Replace comma with dot for decimal
      final normalized = str.replaceAll(',', '.');
      return double.parse(normalized);
    } catch (_) {
      return null;
    }
  }

  /// Parse price string (removes thousand separators)
  double? _parsePrice(String str) {
    try {
      // Remove thousand separators (dots or commas)
      final normalized = str.replaceAll('.', '').replaceAll(',', '');
      return double.parse(normalized);
    } catch (_) {
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    _textRecognizer.close();
  }
}
