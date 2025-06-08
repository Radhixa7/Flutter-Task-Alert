plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin harus di paling akhir
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.task_alert_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.task_alert_flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Untuk fitur Java 8+ seperti java.time.*, diperlukan oleh beberapa plugin
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Tambahan dependencies jika diperlukan oleh plugin lain
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
}

flutter {
    source = "../.."
}
