package dev.dotcmake;
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.io.File
import java.io.FileNotFoundException

@Serializable
data class Project(
    val Name: String,
    val ID: String,
    val Version: String,
    val Description: String? = null,
    val URL: String? = null
)
@Serializable
data class Config(val Project: Project)

object CMake {
    private val json = Json { ignoreUnknownKeys = true }

    fun readConfig(file: File): Config {
        if (!file.exists()){
            throw FileNotFoundException("${file.absolutePath} not found!")
        }
        val jsonString = file.readText(Charsets.UTF_8)
        return json.decodeFromString(Config.serializer(), jsonString)
    }
}
