
# Flutter ProGuard rules

# Flutter's entry points
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.** { *; }

# Keep classes that are used for reflection in Flutter plugins
-keep class com.google.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotations from being stripped
-keepattributes Annotation

# Required for Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep code that uses reflection and serialization (commonly needed for Gson or JSON parsing)
-keepclassmembers class *.R$ {
    public static <fields>;
}

# Keep native libraries and symbols intact for crash reporting
-keep class com.crashlytics.** { *; }
-keep class io.sentry.** { *; }

#extra rules
-keep interface * {
    @retrofit2.http.* <methods>;
}
# Keep Retrofit core classes
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

-keep class org.jsoup.** { *; }
-dontwarn org.jsoup.**

#end of extra rules

# Third-party suggested rules (Retrofit, Gson, Kotlin Coroutines)
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation
-if interface * { @retrofit2.http.* public *** *(...); }
-keep,allowoptimization,allowshrinking,allowobfuscation class <3>
-keep,allowobfuscation,allowshrinking class retrofit2.Response
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken


# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn com.google.api.client.http.GenericUrl
-dontwarn com.google.api.client.http.HttpHeaders
-dontwarn com.google.api.client.http.HttpRequest
-dontwarn com.google.api.client.http.HttpRequestFactory
-dontwarn com.google.api.client.http.HttpResponse
-dontwarn com.google.api.client.http.HttpTransport
-dontwarn com.google.api.client.http.javanet.NetHttpTransport$Builder
-dontwarn com.google.api.client.http.javanet.NetHttpTransport
-dontwarn org.joda.time.Instant


# Optional: If you're using third-party SDKs like MoEngage, you may need to include additional rules provided by the SDK.
# Add rules for other third-party SDKs (check their documentation for specific ProGuard rules).

# You can add other specific rules for any other libraries you are using to prevent them from being obfuscated



# -keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

#
# # R8 full mode strips generic signatures from return types if not kept.
# -if interface * { @retrofit2.http.* public *** *(...); }
# -keep,allowoptimization,allowshrinking,allowobfuscation class <3>
#
# # With R8 full mode generic signatures are stripped for classes that are not kept.
# -keep,allowobfuscation,allowshrinking class retrofit2.Response
# -keep class com.google.gson.reflect.TypeToken { *; }
# -keep class * extends com.google.gson.reflect.TypeToken