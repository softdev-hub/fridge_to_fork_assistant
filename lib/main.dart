import 'package:flutter/material.dart';
import 'package:fridge_to_fork_assistant/views/welcome/welcome_view.dart';
import 'package:fridge_to_fork_assistant/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzemF0YnpsbW50ZGh4Y2h1cnVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMzk4NTAsImV4cCI6MjA3OTcxNTg1MH0.ccCNKFZpOjfV-K_AGDiYco0wELAznz6wY0is7YKrQ4I",
    url: "https://uszatbzlmntdhxchuruj.supabase.co",
  );

  // Initialize notification service
  await NotificationService.initialize();
  await NotificationService.initializeWorkmanager();
  // Request notification permission on Android 13+
  await NotificationService.requestAndroidPermission();
  // Schedule daily notification check at 8:00 AM
  await NotificationService.scheduleDailyCheck();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeView(),
    );
  }
}
