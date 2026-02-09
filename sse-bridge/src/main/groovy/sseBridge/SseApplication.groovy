package sseBridge

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.data.r2dbc.repository.config.EnableR2dbcRepositories

@SpringBootApplication
@EnableR2dbcRepositories
class SseApplication {

    static void main(String[] args) {
        System.setProperty("spring.devtools.restart.enabled", "true")
        SpringApplication.run(SseApplication.class, args)
    }
}
