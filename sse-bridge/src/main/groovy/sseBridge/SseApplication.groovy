package sseBridge

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
class SseApplication {

    static void main(String[] args) {
        SpringApplication.run(SseApplication.class, args)
    }
}
