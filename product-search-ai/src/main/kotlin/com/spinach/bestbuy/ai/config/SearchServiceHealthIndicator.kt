package com.spinach.bestbuy.ai.config

import com.spinach.bestbuy.ai.services.EmbeddingService
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.actuate.health.Health
import org.springframework.boot.actuate.health.HealthIndicator
import org.springframework.stereotype.Component

@Component
class SearchServiceHealthIndicator(private val embeddingService: EmbeddingService) : HealthIndicator {

    override fun health(): Health {
        // Add custom health check logic here
        val isServiceHealthy = checkEmbeddingService()
        return if (isServiceHealthy) Health.up().build() else Health.down()
            .withDetail("Error", "Service Unavailable as EmbeddingService down")
            .build()
    }

    private fun checkEmbeddingService(): Boolean {
        // check logic to verify the health of the search service such as embedding service is live
        return runCatching {
            embeddingService.generateEmbedding("sample-text").isNotEmpty()
        }.getOrDefault(false)
    }
}
