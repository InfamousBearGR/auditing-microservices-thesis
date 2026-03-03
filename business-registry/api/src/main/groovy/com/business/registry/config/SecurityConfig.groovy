package com.business.registry.config

import com.business.registry.filter.SessionAuthenticationFilter
import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource

@Configuration
@EnableWebSecurity
@CompileStatic
class SecurityConfig {

    private final SessionAuthenticationFilter sessionAuthenticationFilter

    @Value('${cors.allowed-origins:http://localhost:5000}')
    private String allowedOrigins

    SecurityConfig(SessionAuthenticationFilter sessionAuthenticationFilter) {
        this.sessionAuthenticationFilter = sessionAuthenticationFilter
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .cors { cors ->
                cors.configurationSource(corsConfigurationSource())
            }
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

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration()
        configuration.setAllowedOrigins(allowedOrigins.split(',').toList())
        configuration.setAllowedMethods(['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'])
        configuration.setAllowedHeaders(['*'])
        configuration.setAllowCredentials(true)

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource()
        source.registerCorsConfiguration('/**', configuration)
        return source
    }
}


