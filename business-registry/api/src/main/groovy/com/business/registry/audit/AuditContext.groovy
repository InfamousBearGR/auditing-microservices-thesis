package com.business.registry.audit

import groovy.transform.CompileStatic

/**
 * Thread-local carrier for Envers revision attribution.
 *
 * Populated per request by {@link AuditContextFilter} (user id pulled from the
 * HTTP session) and read by {@link AuditRevisionListener} when Envers creates a
 * new REVINFO row. Same request thread runs the controller, the @Transactional
 * service and the Envers flush, so a ThreadLocal reaches the listener intact.
 *
 * Only relevant when the 'envers' Spring profile is active; harmless otherwise.
 */
@CompileStatic
class AuditContext {

    private static final ThreadLocal<Long> USER_ID = new ThreadLocal<>()
    private static final ThreadLocal<String> CHANGE_REASON = new ThreadLocal<>()

    static void setUserId(Long userId) { USER_ID.set(userId) }

    static Long getUserId() { return USER_ID.get() }

    static void setChangeReason(String reason) { CHANGE_REASON.set(reason) }

    static String getChangeReason() { return CHANGE_REASON.get() }

    static void clear() {
        USER_ID.remove()
        CHANGE_REASON.remove()
    }
}
