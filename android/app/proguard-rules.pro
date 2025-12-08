# Flutter混淆规则

# 保留Flutter引擎
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 保留Dart代码
-keep class com.uyghurtranslator.** { *; }

# 保留JSON序列化
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# 保留Firebase
-keep class com.google.firebase.** { *; }

# 保留ML Kit
-keep class com.google.mlkit.** { *; }

# 保留Isar数据库
-keep class dev.isar.** { *; }

# 保留Hive
-keep class com.hivedb.** { *; }

# 移除日志
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
