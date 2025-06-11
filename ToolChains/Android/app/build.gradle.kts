import java.util.Locale
import java.util.Calendar
import java.util.TimeZone

import dev.dotcmake.Config
import dev.dotcmake.CMake

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.serialization)
}

android {
    namespace = "com.diyou.dotcmake"
    compileSdk = 36
    ndkVersion = "29.0.13113456"

    val sourceRoot: File = rootProject.file("../../..")

    defaultConfig {
        minSdk = 26
        targetSdk = 36

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        val timezone = TimeZone.getTimeZone("UTC")
        val calendar = Calendar.getInstance(timezone, Locale.ROOT)

        val year    = calendar.get(Calendar.YEAR) - 2000
        val day     = calendar.get(Calendar.DAY_OF_YEAR)
        val minute  = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)

        versionCode = (year * 1_000_000) + (day * 10_000) + minute

        val configFile = File(sourceRoot, "Project.json")

        val config: Config = CMake.readConfig(configFile)
        applicationId = config.Project.ID
        versionName = config.Project.Version
        resValue("string", "app_name", config.Project.Name)

        externalNativeBuild {
            cmake {
                arguments += "-DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=${File(sourceRoot,".cmake/ToolChains/gradle/callback.cmake").absolutePath}"
            }
        }

        // Remove for 32bit support
        ndk {
            abiFilters.clear()
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    externalNativeBuild {
        cmake {
            path = File(sourceRoot, "CMakeLists.txt")
            version = "4.0.2"
        }
    }
    buildFeatures {
        viewBinding = true
        prefab = true
    }
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.constraintlayout)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    implementation(libs.kotlinx.serialization.json)

    implementation(files("libs/SDL3/SDL3-3.2.14.aar"))
}
