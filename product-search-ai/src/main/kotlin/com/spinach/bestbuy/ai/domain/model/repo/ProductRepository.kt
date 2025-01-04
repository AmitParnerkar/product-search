package com.spinach.bestbuy.ai.domain.model.repo

import com.spinach.bestbuy.ai.domain.model.Product
import org.springframework.data.mongodb.repository.MongoRepository

interface ProductRepository : MongoRepository<Product, String> {
    fun findByName(name: String): Product?
}

