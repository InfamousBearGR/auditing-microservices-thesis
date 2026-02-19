package com.business.registry.filter

import com.business.registry.service.AuthenticationService
import groovy.transform.CompileStatic
import jakarta.servlet.FilterChain
import jakarta.servlet.ServletException
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import jakarta.servlet.http.HttpSession
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

@Component
@CompileStatic
class SessionAuthenticationFilter extends OncePerRequestFilter {

    private final AuthenticationService authenticationService

    SessionAuthenticationFilter(AuthenticationService authenticationService) {
        this.authenticationService = authenticationService
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false)

        if (session != null && authenticationService.isAuthenticated(session)) {
            String username = authenticationService.getCurrentUsername(session)
            Long userId = authenticationService.getCurrentUserId(session)

            // Create authentication token with user info
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    username,
                    null,
                    [new SimpleGrantedAuthority("ROLE_USER")]
            )
            authentication.setDetails(userId)

            // Set authentication in security context
            SecurityContextHolder.getContext().setAuthentication(authentication)
        }

        filterChain.doFilter(request, response)
    }
}

