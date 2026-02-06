package sseBridge

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
class SseApplication {

    static void main(String[] args) {
        System.setProperty("spring.devtools.restart.enabled", "true")
        SpringApplication.run(SseApplication.class, args)
    }
}
