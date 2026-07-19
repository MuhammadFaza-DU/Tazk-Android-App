# flutter_local_notifications uses Gson with generic types via reflection.
# R8/ProGuard strips generic signatures and TypeToken subclasses in release
# builds, causing "Missing type parameter" at runtime. Keep them.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# Gson model classes serialized by the plugin must retain their fields.
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
