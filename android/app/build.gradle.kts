plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.women_safety"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.women_safety"
        
        // Use 21 manually to support Firebase, Google Maps, and OSRM
        minSdk = flutter.minSdkVersion 
        targetSdk = 34
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            // Using debug signing for testing purposes
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
