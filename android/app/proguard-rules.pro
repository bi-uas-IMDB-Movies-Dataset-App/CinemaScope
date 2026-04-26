# CinemaScope ProGuard Rules

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase / Postgrest
-keep class com.supabase.** { *; }
-keep class io.github.jan.supabase.** { *; }
-keep class io.ktor.** { *; }

# Keep JSON serialization for models if using reflection
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

