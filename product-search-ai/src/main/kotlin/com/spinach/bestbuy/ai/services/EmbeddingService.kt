package com.spinach.bestbuy.ai.services
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.springframework.stereotype.Service
import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import org.springframework.beans.factory.annotation.Value
import kotlin.math.sqrt

@Service
class EmbeddingService {

    private val client = OkHttpClient()
    private val objectMapper = jacksonObjectMapper()
    @Value("\${embedding-service.url}")
    private lateinit var pythonServiceUrl: String

    fun generateEmbedding(text: String): List<Double> {
        try {
            // Prepare request payload
            val jsonPayload = objectMapper.writeValueAsString(mapOf("text" to text))
            val requestBody = jsonPayload.toRequestBody("application/json".toMediaType())

            // Make HTTP POST request
            val request = Request.Builder()
                .url(pythonServiceUrl)
                .post(requestBody)
                .build()

            client.newCall(request).execute().use { response ->
                if (!response.isSuccessful) {
                    throw RuntimeException("Unexpected code $response")
                }

                // Parse response
                val responseBody = response.body?.string()
                val responseMap: Map<String, Any> = objectMapper.readValue(responseBody!!)
                return responseMap["embedding"] as List<Double>
            }
        } catch (e: Exception) {
            throw RuntimeException("Error generating embeddings: ${e.message}", e)
        }
    }

    fun cosineSimilarity(vec1: List<Double>, vec2: List<Double>): Double {
        val dotProduct = vec1.zip(vec2).sumOf { it.first * it.second }
        val magnitude1 = sqrt(vec1.sumOf { it * it })
        val magnitude2 = sqrt(vec2.sumOf { it * it })
        return dotProduct / (magnitude1 * magnitude2)
    }
}


