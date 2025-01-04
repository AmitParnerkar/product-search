package com.spinach.bestbuy.ai.config
import com.hazelcast.config.Config
import com.hazelcast.config.MapConfig
import org.springframework.cache.annotation.EnableCaching
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
@EnableCaching
class HazelcastConfig {

    @Bean(name = ["customHazelcastInstance"])
    fun hazelcastConfig(): Config {
        return Config().apply {
            addMapConfig(
                MapConfig("searchCache")
                    .setTimeToLiveSeconds(300)
            )
        }
    }
}
