plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.yalla_mazra3a"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.yalla_mazra3a"
        minSdk = 27
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("release") {
            val keystoreProps = rootProject.extra["keystoreProperties"] as java.util.Properties

            val storeFileName = keystoreProps["storeFile"]?.toString() ?: throw GradleException("Missing storeFile")
            val storePassword = keystoreProps["storePassword"]?.toString() ?: throw GradleException("Missing storePassword")
            val keyAlias = keystoreProps["keyAlias"]?.toString() ?: throw GradleException("Missing keyAlias")
            val keyPassword = keystoreProps["keyPassword"]?.toString() ?: throw GradleException("Missing keyPassword")

            storeFile = rootProject.file(storeFileName)
            this.storePassword = storePassword
            this.keyAlias = keyAlias
            this.keyPassword = keyPassword
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.12.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.android.gms:play-services-auth:21.0.0")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation ("com.google.android.material:material:1.5.0")
    implementation ("androidx.core:core-splashscreen:1.0.0")

}
