package com.spinach.bestbuy.ai.api

import com.spinach.bestbuy.ai.domain.model.Product
import com.spinach.bestbuy.ai.domain.model.repo.ProductRepository
import com.spinach.bestbuy.ai.services.EmbeddingService
import io.github.resilience4j.retry.annotation.Retry
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.cache.annotation.Cacheable
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/products")
@Tag(name = "Best Buy Product API", description = "Smart AI based search for Best Buy products")
class BestBuyProductController(
    private val embeddingService: EmbeddingService,
    private val productRepository: ProductRepository,
) {

    @Operation(
        summary = "Add a product",
        description = "Adds a product to the repository and generates an embedding for it",
        responses = [
            ApiResponse(description = "Product saved successfully", responseCode = "200"),
            ApiResponse(description = "Invalid input", responseCode = "400", content = [Content()])
        ]
    )
    @PostMapping("/add")
    @Retry(name = "embeddingService", fallbackMethod = "fallbackForAddItem")
    fun addItem(@RequestBody item: Product): String {
        val embedding = embeddingService.generateEmbedding(item.description)
        val newItem = item.copy(embedding = embedding)
        productRepository.save(newItem)
        return "Item saved successfully!"
    }

    @Operation(
        summary = "Search products",
        description = "Searches for products based on a query string embedding and returns the top 5 most similar items",
        responses = [
            ApiResponse(description = "Search results", responseCode = "200"),
            ApiResponse(description = "No products found", responseCode = "404", content = [Content()])
        ]
    )
    @GetMapping("/search")
    @Retry(name = "embeddingService", fallbackMethod = "fallbackForSearchItems")
    @Cacheable(value = ["searchCache"], key = "#query")
    fun searchItems(@RequestParam query: String): List<List<String>> {
        val queryEmbedding = embeddingService.generateEmbedding(query)
        val minSimilarityThreshold = 0.7
        return productRepository.findAll()
            .map { it to it.embedding?.let { it1 -> embeddingService.cosineSimilarity(it1, queryEmbedding) } } // Pair product with similarity score
            .filter { it.second!! >= minSimilarityThreshold } // Filter by threshold
            .sortedByDescending { it.second } // Sort by similarity
            .take(5) // Limit to top 5 results
            .map { listOf(it.first.name, it.first.description, it.first.category) } // Extract the product
    }

    // Fallback methods
    fun fallbackForAddItem(item: Product, ex: Throwable): String {
        return "Failed to save product: ${ex.message}"
    }

    fun fallbackForSearchItems(query: String, ex: Throwable): List<List<String>> {
        return emptyList()
    }
}