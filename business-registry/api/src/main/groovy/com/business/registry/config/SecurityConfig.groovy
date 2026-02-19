package com.business.registry.config

import com.business.registry.filter.SessionAuthenticationFilter
import groovy.transform.CompileStatic
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter

@Configuration
@EnableWebSecurity
@CompileStatic
class SecurityConfig {

    private final SessionAuthenticationFilter sessionAuthenticationFilter

    SecurityConfig(SessionAuthenticationFilter sessionAuthenticationFilter) {
        this.sessionAuthenticationFilter = sessionAuthenticationFilter
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests { authz ->
                authz
                    .requestMatchers("/api/auth/**").permitAll()  // Allow authentication endpoints
                    .anyRequest().authenticated()  // Require authentication for all other requests
            }
            .addFilterBefore(sessionAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
            .sessionManagement { session ->
                session.maximumSessions(1)  // Allow only one session per user
            }
            .httpBasic { basic ->
                basic.disable()  // Disable basic auth since we're using session-based authentication
            }
            .formLogin { form ->
                form.disable()  // Disable form login since we're using custom authentication
            }
            .csrf { csrf ->
                csrf.disable()  // Disable CSRF for API endpoints
            }

        return http.build()
    }
}


