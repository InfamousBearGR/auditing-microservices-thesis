package com.business.registry.service

import com.business.registry.dto.authentication.LoginRequestDto
import com.business.registry.dto.authentication.LoginResponseDto
import com.business.registry.dto.authentication.LogoutResponseDto
import com.business.registry.exception.UnauthorizedException
import com.business.registry.model.UserAccount
import com.business.registry.repository.UserAccountRepository
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service

@Service
@CompileStatic
class AuthenticationService {

    private static final String SESSION_USER_ID_KEY = "userId"
    private static final String SESSION_USERNAME_KEY = "username"
    private static final String SESSION_ROLE_KEY = "role"

    @Autowired
    UserAccountRepository userAccountRepository

    @Autowired
    PasswordService passwordService

    @Autowired
    MessageService messageService

    /**
     * Authenticate a user with username and password
     * @param username The username
     * @param password The plain text password
     * @param session The HTTP session
     * @return The authenticated UserAccount if successful, null otherwise
     */
    UserAccount login(String username, String password, HttpSession session) {
        Optional<UserAccount> userOpt = userAccountRepository.findByUsername(username)

        if (!userOpt.isPresent()) {
            return null
        }

        UserAccount user = userOpt.get()

        if (!passwordService.verifyPassword(password, user.passwordHash)) {
            return null
        }

        // Store user info in session
        session.setAttribute(SESSION_USER_ID_KEY, user.id)
        session.setAttribute(SESSION_USERNAME_KEY, user.username)
        session.setAttribute(SESSION_ROLE_KEY, user.role.id)

        return user
    }

    /**
     * Logout the current user
     * @param session The HTTP session
     */
    static void logout(HttpSession session) {
        session.invalidate()
    }

    /**
     * Get the currently authenticated user ID from session
     * @param session The HTTP session
     * @return The user ID if authenticated, null otherwise
     */
    static Long getCurrentUserId(HttpSession session) {
        Object userId = session.getAttribute(SESSION_USER_ID_KEY)
        return userId ? userId as Long : null
    }

    /**
     * Get the currently authenticated username from session
     * @param session The HTTP session
     * @return The username if authenticated, null otherwise
     */
    static String getCurrentUsername(HttpSession session) {
        return session.getAttribute(SESSION_USERNAME_KEY) as String
    }

    static Long getCurrentUserRole(HttpSession session) {
        Object roleId = session.getAttribute(SESSION_ROLE_KEY)
        return roleId ? roleId as Long : null
    }

    /**
     * Check if a user is authenticated
     * @param session The HTTP session
     * @return true if authenticated, false otherwise
     */
    static boolean isAuthenticated(HttpSession session) {
        return getCurrentUserId(session) != null
    }

    /**
     * Handle login request with full validation and response creation
     * @param loginRequest The login request DTO
     * @param session The HTTP session
     * @return ResponseEntity with appropriate response
     */
    LoginResponseDto handleLogin(LoginRequestDto loginRequest, HttpSession session) {
        if (isAuthenticated(session)) {
            throw new IllegalStateException(messageService.getMessage("Είστε.ήδη.συνδεδεμένοι."))
        }

        UserAccount user = login(
                loginRequest.username,
                loginRequest.password,
                session
        )

        if (!user) {
            throw new UnauthorizedException(messageService.getMessage("Λάθος.username.ή.password."))
        }

        return new LoginResponseDto(
                userId: user.id,
                username: user.username,
                authenticated: true,
                role: user.role.id
        )
    }

    /**
     * Handle logout request with full validation and response creation
     * @param session The HTTP session
     * @return ResponseEntity with appropriate response
     */
    LogoutResponseDto handleLogout(HttpSession session) {
        if (!isAuthenticated(session)) {
            throw new IllegalStateException(messageService.getMessage("Δεν.είστε.συνδεδεμένοι."))
        }

        logout(session)

        return new LogoutResponseDto(message: messageService.getMessage("Επιτυχής.αποσύνδεση."))
    }

    /**
     * Handle status request with full validation and response creation
     * @param session The HTTP session
     * @return ResponseEntity with appropriate response
     */
    static LoginResponseDto handleGetStatus(HttpSession session) {
        Long userId = getCurrentUserId(session)
        String username = getCurrentUsername(session)
        Long roleId = getCurrentUserRole(session)

        return new LoginResponseDto(
                userId: userId,
                username: username,
                authenticated: isAuthenticated(session),
                role: roleId
        )
    }
}

