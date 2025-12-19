import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/scanned_receipt_item.dart';
import '../../services/receipt_scanner_service.dart';
import 'add_pantry_view.dart';
import 'components/pantry_constants.dart';
import 'components/pantry_header.dart';

class ScanReceiptView extends StatefulWidget {
  const ScanReceiptView({super.key});

  @override
  State<ScanReceiptView> createState() => _ScanReceiptViewState();
}

class _ScanReceiptViewState extends State<ScanReceiptView> {
  final ReceiptScannerService _scannerService = ReceiptScannerService();
  final ImagePicker _picker = ImagePicker();

  File? _capturedImage;
  List<ScannedReceiptItem> _scannedItems = [];
  bool _isScanning = false;
  String? _errorMessage;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _errorMessage = null;
        });
        await _scanReceipt();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi chọn ảnh: $e';
      });
    }
  }

  Future<void> _scanReceipt() async {
    if (_capturedImage == null) return;

    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final items = await _scannerService.scanReceipt(_capturedImage!);
      setState(() {
        _scannedItems = items;
        _isScanning = false;
      });

      if (items.isEmpty) {
        setState(() {
          _errorMessage = 'Không nhận dạng được sản phẩm nào từ hóa đơn.';
        });
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
        _errorMessage = 'Lỗi quét hóa đơn: $e';
      });
    }
  }

  void _navigateToAddPantry(ScannedReceiptItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPantryView(
          initialName: item.name,
          initialQuantity: item.quantity,
          initialUnit: item.unit,
          initialImage: _capturedImage,
          initialPurchaseDate: DateTime.now(),
        ),
      ),
    );

    if (result == true) {
      // Item was added successfully, remove from list
      setState(() {
        _scannedItems.remove(item);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${item.name}" vào kho!'),
            backgroundColor: PantryConstants.primaryColor,
          ),
        );
      }

      // If all items added, go back
      if (_scannedItems.isEmpty) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? PantryConstants.backgroundDark
          : PantryConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            PantryHeader(
              title: 'Quét Hóa Đơn',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(isDark),
                    const SizedBox(height: 16),
                    _buildActionButtons(isDark),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) _buildErrorMessage(isDark),
                    if (_isScanning) _buildLoadingIndicator(),
                    if (_scannedItems.isNotEmpty) ...[
                      _buildResultsHeader(isDark),
                      const SizedBox(height: 12),
                      _buildScannedItemsList(isDark),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(PantryConstants.borderRadiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PantryConstants.borderRadiusLarge - 2),
        child: _capturedImage != null
            ? Image.file(
                _capturedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chụp hoặc chọn ảnh hóa đơn',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Chụp ảnh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PantryConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: Icon(
              Icons.photo_library,
              color: isDark ? Colors.grey[200] : Colors.grey[800],
            ),
            label: Text(
              'Thư viện',
              style: TextStyle(
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PantryConstants.borderRadius),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        children: [
          CircularProgressIndicator(color: PantryConstants.primaryColor),
          SizedBox(height: 16),
          Text('Đang nhận dạng sản phẩm...'),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Đã nhận dạng ${_scannedItems.length} sản phẩm',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[200] : Colors.grey[800],
          ),
        ),
        TextButton(
          onPressed: _scannedItems.isNotEmpty
              ? () {
                  // Add all items functionality could be implemented here
                }
              : null,
          child: const Text('Thêm tất cả'),
        ),
      ],
    );
  }

  Widget _buildScannedItemsList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(PantryConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _scannedItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? Colors.grey[700] : Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final item = _scannedItems[index];
          return _buildScannedItemTile(item, isDark);
        },
      ),
    );
  }

  Widget _buildScannedItemTile(ScannedReceiptItem item, bool isDark) {
    // Format quantity nicely
    String quantityStr;
    if (item.quantity >= 1000 && item.unit.displayName == 'g') {
      quantityStr = '${(item.quantity / 1000).toStringAsFixed(2)} kg';
    } else if (item.quantity >= 1000 && item.unit.displayName == 'ml') {
      quantityStr = '${(item.quantity / 1000).toStringAsFixed(2)} L';
    } else {
      quantityStr = '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.unit.displayName}';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: PantryConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.shopping_basket,
          color: PantryConstants.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        item.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey[100] : Colors.grey[900],
        ),
      ),
      subtitle: Text(
        quantityStr,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
      ),
      onTap: () => _navigateToAddPantry(item),
    );
  }
}
