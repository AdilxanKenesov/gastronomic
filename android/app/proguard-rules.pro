# Yandex MapKit
-keep class com.yandex.mapkit.** { *; }
-keep class com.yandex.runtime.** { *; }
-dontwarn com.yandex.**

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Retrofit / OkHttp (http package ichki ishlatadi)
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep enums
-keepclassmembers enum * { *; }