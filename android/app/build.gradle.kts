plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myapp"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        applicationId = "com.example.myapp"
        minSdkVersion(flutter.minSdkVersion)
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // Updated to 2.1.4
    }
}

flutter {
    source = "../../"
}

tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:unchecked")
    options.compilerArgs.add("-Xlint:deprecation")
}
