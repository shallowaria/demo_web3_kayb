plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    // 1. 在这里添加 Google 服务插件
    id("com.google.gms.google-services")
    // Flutter 插件必须放在后面
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // 1. 定义签名配置
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]
            keyPassword = keystoreProperties["keyPassword"]
            storeFile = file(keystoreProperties["storeFile"]!!)
            storePassword = keystoreProperties["storePassword"]
        }
    }

    namespace = "com.example.web3_demo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        // 确认这里的 applicationId 和你在 Firebase 后台填的一致
        applicationId = "com.example.web3_demo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

buildTypes {
        release {
            // 2. 将调试签名换成你的正式签名
            signingConfig = signingConfigs.getByName("release")
            
            // 3. 确认启用混淆（对应你之前的步骤）
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// 文件末尾添加
dependencies {
    // 导入 Firebase BoM (管理版本号)
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    // 添加云消息传递库
    implementation("com.google.firebase:firebase-messaging")
}