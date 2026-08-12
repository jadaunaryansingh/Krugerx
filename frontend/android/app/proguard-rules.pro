# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
# Isar native binding
-keep class dev.isar.** { *; }
# Flutter references Play Core for deferred components — not used here, suppress missing-class errors
-dontwarn com.google.android.play.core.**
