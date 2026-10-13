package sseBridge.auth

import org.springframework.stereotype.Service
import reactor.core.publisher.Mono

@Service
class AuthService {

    private final ApiUserAccountRepository apiUserAccountRepository

    AuthService(ApiUserAccountRepository apiUserAccountRepository) {
        this.apiUserAccountRepository = apiUserAccountRepository
    }

    Mono<ApiUserAccount> authenticate(String apiKey) {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return Mono.empty()
        }
        return apiUserAccountRepository.findByApiKey(apiKey)
    }

    static boolean authorize(ApiUserAccount user, String resource) {
        if (user == null || resource == null) {
            return false
        }
        return user.hasAccess(resource)
    }
}

