-dontwarn com.netease.**
-keep class com.netease.** {*;}

# 如果你使用全文检索插件，需要加入
-dontwarn org.apache.lucene.**
-keep class org.apache.lucene.** {*;}

# 小米 push
-dontwarn com.xiaomi.push.**
-keep class com.xiaomi.** {*;}

# 华为 push
-ignorewarning
-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keep class com.hianalytics.android.**{*;}
-keep class com.huawei.updatesdk.**{*;}
-keep class com.huawei.hms.**{*;}

# 魅族
-dontwarn com.meizu.cloud.**
-keep class com.meizu.cloud.** {*;}

# OPPO push
-keep public class * extends android.app.Service

# VIVO push
-dontwarn com.vivo.push.**
-keep class com.vivo.push.**{*; }
-keep class com.vivo.vms.**{*; }
-keep class com.netease.nimlib.mixpush.vivo.VivoPush* {*;}
-keep class com.netease.nimlib.mixpush.vivo.VivoPushReceiver{*;}
