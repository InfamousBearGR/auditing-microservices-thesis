package com.business.registry.audit

import groovy.transform.CompileStatic
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import jakarta.servlet.http.HttpSession
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

/**
 * Populates {@link AuditContext} with the current user id (from the HTTP session,
 * same "userId" attribute AuthenticationService uses) at the start of each request
 * and clears it afterwards. This gives the Envers {@link AuditRevisionListener}
 * the acting user for the REVINFO row without touching any service method.
 *
 * change_reason is NOT set here (it lives in the request body, per-mutation) — it
 * already survives in every audited <table>_AUD row via the entity's own
 * change_reason column, so REVINFO.change_reason is left to opt-in callers.
 */
@Component
@Order(0)
@CompileStatic
class AuditContextFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) {
        try {
            HttpSession session = request.getSession(false)
            if (session != null) {
                Object userId = session.getAttribute("userId")
                if (userId != null) {
                    AuditContext.setUserId(userId as Long)
                }
            }
            filterChain.doFilter(request, response)
        } finally {
            AuditContext.clear()
        }
    }
}
