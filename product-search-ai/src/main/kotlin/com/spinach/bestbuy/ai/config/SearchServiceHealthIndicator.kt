package com.spinach.bestbuy.ai.config

import com.spinach.bestbuy.ai.services.LLMService
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.actuate.health.Health
import org.springframework.boot.actuate.health.HealthIndicator
import org.springframework.stereotype.Component

@Component
class SearchServiceHealthIndicator(private val llmService: LLMService) : HealthIndicator {

    override fun health(): Health {
        // Add custom health check logic here
        val isServiceHealthy = checkLLMService()
        return if (isServiceHealthy) Health.up().build() else Health.down()
            .withDetail("Error", "Service Unavailable as LLMService down")
            .build()
    }

    private fun checkLLMService(): Boolean {
        // check logic to verify the health of the search service such as embedding service is live
        return runCatching {
            llmService.generateEmbedding("sample-text").isNotEmpty()
        }.getOrDefault(false)
    }
}
