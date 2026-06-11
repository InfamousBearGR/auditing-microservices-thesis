package com.business.registry.audit

import groovy.transform.CompileStatic
import org.hibernate.envers.RevisionListener

/**
 * Stamps each Envers revision (REVINFO row) with the acting user and change
 * reason taken from {@link AuditContext} (populated per request by
 * {@link AuditContextFilter}). Invoked by Envers on the request thread during
 * the transaction's flush, so the ThreadLocal is still in scope.
 */
@CompileStatic
class AuditRevisionListener implements RevisionListener {

    @Override
    void newRevision(Object revisionEntity) {
        AuditRevisionEntity rev = (AuditRevisionEntity) revisionEntity
        rev.changedByUserId = AuditContext.getUserId()
        rev.changeReason = AuditContext.getChangeReason()
    }
}
