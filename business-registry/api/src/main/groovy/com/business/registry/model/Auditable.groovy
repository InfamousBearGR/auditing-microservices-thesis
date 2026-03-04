package com.business.registry.model

/**
 * Marker interface for entities that carry auditing fields.
 * Any entity that has {@code lastUser} and {@code changeReason} columns
 * should implement this interface so that {@link com.business.registry.service.DeleteService}
 * can stamp audit information before a cascading delete.
 */
interface Auditable {
    Long getId()

    UserAccount getLastUser()
    void setLastUser(UserAccount user)

    String getChangeReason()
    void setChangeReason(String reason)
}

