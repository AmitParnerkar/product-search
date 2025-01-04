package com.spinach.bestbuy.ai.domain.model

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document

@Document(collection = "products")
data class Product(
    @Id val id: String? = null,
    val name: String,          // Item name
    val description: String,   // Item description
    val category: String,      // Category (optional)
    val embedding: List<Double>? = null // Make it nullable
)