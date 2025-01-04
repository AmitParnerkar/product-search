package com.spinach.bestbuy.ai.services

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.type.TypeFactory
import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.spinach.bestbuy.ai.domain.model.Product
import com.spinach.bestbuy.ai.domain.model.repo.ProductRepository
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.asm.TypeReference
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.event.EventListener
import org.springframework.core.io.ResourceLoader
import org.springframework.stereotype.Service

@Service
class StartupDataLoader(
    private val productRepository: ProductRepository,
    private val resourceLoader: ResourceLoader,
    private val embeddingService: EmbeddingService,
    private val logger: Logger = LoggerFactory.getLogger(StartupDataLoader::class.java)

) {

    @EventListener(ApplicationReadyEvent::class)
    fun loadInitialData() {
        val resource = resourceLoader.getResource("classpath:products.json")
        val inputStream = resource.inputStream

        val objectMapper = jacksonObjectMapper()

        // Define the type of the list using TypeReference
        val productListType = TypeFactory.defaultInstance().constructCollectionType(List::class.java, Product::class.java)
        val products: List<Product> = objectMapper.readValue(inputStream, productListType)

        // Iterate through each product and save it if not already present
        for (product in products) {
            if (productRepository.findByName(product.name) == null) {
                val embedding = embeddingService.generateEmbedding(product.description)
                val newProduct = product.copy(embedding = embedding)
                productRepository.save(newProduct)
                logger.debug("Loaded product: ${newProduct.name}")
            } else {
                logger.debug("Product already exists: ${product.name}")
            }
        }

    }
}
