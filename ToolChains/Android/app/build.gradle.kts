import groovy.json.JsonSlurper

import java.util.Locale
import java.util.Calendar
import java.util.TimeZone

plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "com.diyou.dotcmake"
    compileSdk {
        version = release(37) {
            minorApiLevel = 0
        }
    }
    ndkVersion = "29.0.14206865"

    val sourceRoot: File = rootProject.file("../../..")
    val projectJson = (JsonSlurper().parse(
        file(File(sourceRoot, "Project.json"))
    ) as Map<*, *>)["Project"] as Map<*, *>

    val projectName = projectJson["Name"] as String
    val projectID = projectJson["ID"] as String
    val projectVersion = projectJson["Version"] as String
    val projectDescription = projectJson["Description"] as? String
    val projectURL = projectJson["URL"] as? String

    val timezone = TimeZone.getTimeZone("UTC")
    val calendar = Calendar.getInstance(timezone, Locale.ROOT)

    val year    = calendar.get(Calendar.YEAR) - 2000
    val day     = calendar.get(Calendar.DAY_OF_YEAR)
    val minute  = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)

    defaultConfig {
        manifestPlaceholders["appName"] = projectName
        applicationId = projectID
        minSdk = 24
        targetSdk = 37
        versionCode = (year * 1_000_000) + (day * 10_000) + minute
        versionName = projectVersion
        description = projectDescription

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        externalNativeBuild {
            cmake {
                arguments(
                    "-DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=${File(sourceRoot, ".cmake/ToolChains/android.cmake")}",
                    "-DCMAKE_CXX_STANDARD_LIBRARY=libc++",
                    "-Wno-dev"
                )
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
            optimization {
                enable = false
            }
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    externalNativeBuild {
        cmake {
            path = File(sourceRoot, "CMakeLists.txt")
            buildStagingDirectory = File(sourceRoot, "build/.Android")
            version = "4.1.2"
        }
    }
    buildFeatures {
        viewBinding = true
        prefab = true
    }
}

dependencies {
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.constraintlayout)
    implementation(libs.androidx.core.ktx)
    implementation(libs.material)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(libs.androidx.junit)

    implementation(files("libs/SDL3/SDL3-3.4.10.aar"))
}
