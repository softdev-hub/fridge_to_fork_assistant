import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Service để quản lý upload/delete ảnh lên Supabase Storage
class StorageService {
  static const String _bucketName = 'pantry-images';
  
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload ảnh lên Supabase Storage
  /// Trả về public URL của ảnh đã upload
  Future<String?> uploadPantryImage(File imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Tạo tên file unique với timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = '$userId/$timestamp$extension';

      // Upload file
      await _supabase.storage.from(_bucketName).upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      // Lấy public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Lỗi upload ảnh: $e');
      return null;
    }
  }

  /// Xóa ảnh từ Supabase Storage
  Future<bool> deletePantryImage(String imageUrl) async {
    try {
      // Trích xuất đường dẫn file từ URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // URL format: .../storage/v1/object/public/pantry-images/userId/filename
      // Tìm index của bucket name
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        return false;
      }
      
      // Lấy phần đường dẫn sau bucket name
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage.from(_bucketName).remove([filePath]);
      return true;
    } catch (e) {
      print('Lỗi xóa ảnh: $e');
      return false;
    }
  }

  /// Thay thế ảnh cũ bằng ảnh mới
  /// Xóa ảnh cũ (nếu có) và upload ảnh mới
  Future<String?> replacePantryImage(File newImage, String? oldImageUrl) async {
    // Xóa ảnh cũ nếu có
    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      await deletePantryImage(oldImageUrl);
    }
    
    // Upload ảnh mới
    return uploadPantryImage(newImage);
  }
}
