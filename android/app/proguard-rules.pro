<<<<<<< HEAD
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google ML Kit - Text Recognition
=======
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
<<<<<<< HEAD
-keep class com.google.mlkit.vision.text.latin.** { *; }

# Google ML Kit Commons
-keep class com.google.mlkit.common.** { *; }
-keep class com.google.mlkit.vision.common.** { *; }

# Keep classes referenced by ML Kit
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Preserve annotations
-keepattributes *Annotation*
=======

# Keep Flutter plugin classes
-keep class io.flutter.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# Don't warn about missing classes
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.android.gms.**
>>>>>>> 0c48cac053f03e6f6c27579a5707f6b03fd98619
