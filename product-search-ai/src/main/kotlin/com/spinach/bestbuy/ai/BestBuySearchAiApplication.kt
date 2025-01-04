package com.spinach.bestbuy.ai

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cache.annotation.EnableCaching

@SpringBootApplication
@EnableCaching
class BestBuySearchAiApplication

fun main(args: Array<String>) {
    runApplication<BestBuySearchAiApplication>(*args)
}
