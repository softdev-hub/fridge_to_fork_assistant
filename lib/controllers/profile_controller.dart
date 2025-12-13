import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fridge_to_fork_assistant/models/profile.dart';

class ProfileController {
  final supabase = Supabase.instance.client;

  Future<Profile?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    try {
      final res = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (res == null) return null;
      return Profile.fromJson(Map<String, dynamic>.from(res as Map));
    } catch (_) {
      return null;
    }
  }

  // Create or update profile using upsert
  Future<bool> upsertProfile(Profile profile) async {
    final data = profile.toJson();
    try {
      // some SDK versions return the result directly, some require .execute();
      final res = await supabase
          .from('profiles')
          .upsert(data)
          .select()
          .maybeSingle();
      if (res == null) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  // Update avatar URL only. Returns null on success, or an error message on failure.
  Future<String?> updateAvatar(String userId, String avatarUrl) async {
    try {
      final payload = {'id': userId, 'avatar_url': avatarUrl};
      final res = await supabase
          .from('profiles')
          .upsert(payload)
          .select()
          .maybeSingle();
      if (res == null) return 'No response from server';
      // If SDK returned a Map, assume success
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
