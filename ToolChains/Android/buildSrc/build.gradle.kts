val kotlinxSerialization = "1.8.1"

plugins {
    val kotlinVersion = "2.0.21"
    kotlin("jvm") version kotlinVersion
    id("org.jetbrains.kotlin.plugin.serialization") version kotlinVersion
}

repositories {
    mavenCentral()
    google()
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:$kotlinxSerialization")
    implementation(gradleApi())
}