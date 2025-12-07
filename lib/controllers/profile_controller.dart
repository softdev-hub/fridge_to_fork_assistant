import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fridge_to_fork_assistant/models/profile.dart';

class ProfileController {
  final supabase = Supabase.instance.client;

  Future<Profile?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    try {
      final res = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
      if (res == null) return null;
      // If SDK returns the data directly as a Map
      return Profile.fromJson(Map<String, dynamic>.from(res as Map));
          try {
        final data = (res as dynamic).data;
        if (data == null) return null;
        if (data is Map) return Profile.fromJson(Map<String, dynamic>.from(data));
        if (data is List && data.isNotEmpty) return Profile.fromJson(Map<String, dynamic>.from(data.first as Map));
      } catch (_) {
        // fallthrough
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Create or update profile using upsert
  Future<bool> upsertProfile(Profile profile) async {
    final data = profile.toJson();
    try {
      // some SDK versions return the result directly, some require .execute();
      final res = await supabase.from('profiles').upsert(data).select().maybeSingle();
      if (res == null) return false;
      return true;
      try {
        final error = (res as dynamic).error;
        return error == null;
      } catch (_) {
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  // Update avatar URL only. Returns null on success, or an error message on failure.
  Future<String?> updateAvatar(String userId, String avatarUrl) async {
    try {
      final payload = {'id': userId, 'avatar_url': avatarUrl};
      final res = await supabase.from('profiles').upsert(payload).select().maybeSingle();
      if (res == null) return 'No response from server';
      // If SDK returned a Map, assume success
      return null;
      // Try to extract error information if present
      try {
        final error = (res as dynamic).error;
        if (error != null) return error.toString();
      } catch (_) {}
      // Fallback: success
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
