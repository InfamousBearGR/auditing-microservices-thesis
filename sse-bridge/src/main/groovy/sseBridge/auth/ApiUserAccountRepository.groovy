package sseBridge.auth

import org.springframework.data.r2dbc.repository.Query
import org.springframework.data.r2dbc.repository.R2dbcRepository
import reactor.core.publisher.Mono

interface ApiUserAccountRepository extends R2dbcRepository<ApiUserAccount, Long> {

    @Query("SELECT * FROM user_api_account WHERE api_key = :apiKey")
    Mono<ApiUserAccount> findByApiKey(String apiKey)
}

