import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:fridge_to_fork_assistant/models/profile.dart';
import 'package:fridge_to_fork_assistant/controllers/profile_controller.dart';
import 'package:fridge_to_fork_assistant/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final ProfileController _profileCProfileController = ProfileController();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  // Storage bucket to use for user avatars. Create this bucket in Supabase Storage.
  static const String _storageBucket = 'avatars';

  Profile? _profile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _profileCProfileController.getProfile();
    final email = _auth_service_email();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _nameCtrl.text = p?.name ?? '';
      _emailCtrl.text = email ?? '';
    });
  }

  String? _auth_service_email() => _auth_service_getEmail();

  String? _auth_service_getEmail() {
    try {
      return _auth_service_cachedEmail();
    } catch (_) {
      return null;
    }
  }

  String? _auth_service_cachedEmail() {
    return _auth_service_instance().getCurrentUserEmail();
  }

  AuthService _auth_service_instance() => _auth_service_ref;

  late final AuthService _auth_service_ref = _authService;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy người dùng đăng nhập')));
      setState(() => _saving = false);
      return;
    }

    final profile = Profile(
      id: userId,
      name: _nameCtrl.text.trim(),
      avatarUrl: _profile?.avatarUrl,
      createdAt: _profile?.createdAt,
    );

    final ok = await _profileCProfileController.upsertProfile(profile);
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu hồ sơ thành công')));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu hồ sơ thất bại')));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Chỉnh sửa hồ sơ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // ensure content scrolls above the keyboard
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                const SizedBox(height: 12),
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: _profile?.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) as ImageProvider : null,
                      backgroundColor: const Color(0xFFEFEFEF),
                      child: _profile?.avatarUrl == null ? const Icon(Icons.person, size: 48, color: Colors.grey) : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: const Color(0xFF4CAF50), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF8FAF7), width: 2)),
                          child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            try {
                              final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
                              if (picked == null) return;
                              setState(() => _saving = true);

                              if (!mounted) return;

                              final user = Supabase.instance.client.auth.currentUser;
                              final userId = user?.id;
                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy người dùng đăng nhập')));
                                setState(() => _saving = false);
                                return;
                              }

                              final file = File(picked.path);
                              final ext = p.extension(picked.path);
                              final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$ext';
                              final storage = Supabase.instance.client.storage;

                              // Upload to configured bucket under public/ so it's publicly accessible
                              await storage.from(_storageBucket).upload('public/$fileName', file);

                              // Try to obtain a public URL; SDKs differ in return shapes so handle common cases
                              String? publicUrl;
                              try {
                                final urlRes = storage.from(_storageBucket).getPublicUrl('public/$fileName');
                                // Attempt common access patterns without indexing assuming unknown runtime type
                                try {
                                  publicUrl = (urlRes as dynamic).publicUrl as String?;
                                } catch (_) {}
                                if (publicUrl == null) {
                                  try {
                                    final data = (urlRes as dynamic).data;
                                    if (data is Map && data['publicUrl'] is String) publicUrl = data['publicUrl'] as String?;
                                  } catch (_) {}
                                }
                                publicUrl ??= urlRes.toString();
                              } catch (_) {}

                              if (publicUrl == null) {
                                setState(() => _saving = false);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tạo public URL cho ảnh')));
                                return;
                              }

                              // Debug: log the public URL returned
                              debugPrint('Avatar uploaded to: $publicUrl');
                              // Ensure the client has an authenticated user session matching the userId
                              final current = Supabase.instance.client.auth.currentUser;
                              debugPrint('Current session id: ${current?.id}, userId: $userId');
                              if (current == null || current.id != userId) {
                                setState(() => _saving = false);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phiên đăng nhập không hợp lệ. Vui lòng đăng xuất và đăng nhập lại.')));
                                return;
                              }

                              final err = await _profileCProfileController.updateAvatar(userId, publicUrl);
                              setState(() => _saving = false);
                              if (!mounted) return;
                              if (err == null) {
                                // update local profile to show new avatar instantly
                                setState(() {
                                  _profile = Profile(id: _profile?.id ?? userId, name: _profile?.name, avatarUrl: publicUrl, createdAt: _profile?.createdAt);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật ảnh đại diện')));
                                // show short preview + allow copy (simple)
                                debugPrint('Profile avatar updated for $userId -> $publicUrl');
                              } else {
                                debugPrint('updateAvatar error: $err');
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật ảnh thất bại: $err')));
                              }
                            } catch (e) {
                              setState(() => _saving = false);
                              if (!mounted) return;
                              final msg = e.toString();
                              if (msg.contains('Bucket not found') || msg.contains('bucket not found')) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Bucket storage không tồn tại. Vui lòng tạo bucket có tên "avatars" trong Supabase Storage hoặc cập nhật `_storageBucket` trong mã.')));
                              } else if (msg.contains('row-level security') || msg.contains('violates row-level security') || msg.contains('statusCode: 403') || msg.contains('Unauthorized')) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: RLS (Row Level Security) chặn thao tác. Kiểm tra chính sách RLS và đảm bảo bạn đang đăng nhập đúng người dùng (đăng xuất và đăng nhập lại nếu cần).')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật ảnh: $e')));
                              }
                            }
                          },
                          icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Name field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(border: InputBorder.none, labelText: 'Họ và tên'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                  ),
                ),

                const SizedBox(height: 12),

                // Email field (read-only)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(border: InputBorder.none, labelText: 'Email'),
                    readOnly: true,
                  ),
                ),

                const SizedBox(height: 20),

                // Save and Cancel
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(backgroundColor: const Color(0xFFEFEFEF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Hủy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
