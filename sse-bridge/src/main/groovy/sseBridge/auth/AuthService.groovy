package sseBridge.auth

import org.springframework.stereotype.Service
import reactor.core.publisher.Mono

@Service
class AuthService {

    private final UserAccountRepository userAccountRepository

    AuthService(UserAccountRepository userAccountRepository) {
        this.userAccountRepository = userAccountRepository
    }

    Mono<UserAccount> authenticate(String apiKey) {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return Mono.empty()
        }
        return userAccountRepository.findByApiKey(apiKey)
    }

    static boolean authorize(UserAccount user, String resource) {
        if (user == null || resource == null) {
            return false
        }
        return user.hasAccess(resource)
    }
}

