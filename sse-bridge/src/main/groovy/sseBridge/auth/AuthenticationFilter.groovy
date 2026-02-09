package sseBridge.auth

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Component
import org.springframework.web.server.ServerWebExchange
import org.springframework.web.server.WebFilter
import org.springframework.web.server.WebFilterChain
import reactor.core.publisher.Mono

@Component
class AuthenticationFilter implements WebFilter {

    private static final Logger log = LoggerFactory.getLogger(AuthenticationFilter.class)
    private static final String API_KEY_HEADER = "X-API-Key"
    private static final String USER_ATTRIBUTE = "authenticatedUser"

    private final AuthService authService

    AuthenticationFilter(AuthService authService) {
        this.authService = authService
    }

    @Override
    Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String path = exchange.request.path.value()

        // Only apply authentication to /stream/* endpoints
        if (!path.startsWith("/stream/")) {
            return chain.filter(exchange)
        }

        // Extract API key from header
        String apiKey = exchange.request.headers.getFirst(API_KEY_HEADER)

        if (apiKey == null || apiKey.trim().isEmpty()) {
            log.warn("Missing API key for path: {}", path)
            exchange.response.statusCode = HttpStatus.UNAUTHORIZED
            return exchange.response.setComplete()
        }

        // Authenticate user
        return authService.authenticate(apiKey)
            .flatMap(user -> {
                // Extract resource name from path (e.g., /stream/company -> company)
                String resource = extractResourceFromPath(path)

                // Check if user has access to this resource
                if (!authService.authorize(user, resource)) {
                    log.warn("User with API key {} denied access to resource: {}",
                            apiKey.substring(0, Math.min(8, apiKey.length())) + "...", resource)
                    exchange.response.statusCode = HttpStatus.FORBIDDEN
                    return exchange.response.setComplete()
                }

                // Store user in exchange attributes for use in controller
                exchange.attributes.put(USER_ATTRIBUTE, user)
                log.info("User authenticated successfully for resource: {}", resource)
                return chain.filter(exchange)
            })
            .switchIfEmpty(Mono.defer {
                log.warn("Invalid API key for path: {}", path)
                exchange.response.statusCode = HttpStatus.UNAUTHORIZED
                exchange.response.setComplete()
            })
    }

    private static String extractResourceFromPath(String path) {
        // Extract the table name from /stream/{tableName}
        String[] parts = path.split("/")
        if (parts.length >= 3) {
            return parts[2]
        }
        return ""
    }
}

