# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# Keep text recognition classes specifically
>>>>>>> 0c48cac053f03e6f6c27579a5707f6b03fd98619
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Keep Flutter plugin classes
-keep class io.flutter.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# Don't warn about missing classes
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.android.gms.**