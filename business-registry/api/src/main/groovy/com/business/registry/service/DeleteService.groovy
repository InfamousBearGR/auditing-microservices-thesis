package com.business.registry.service

import com.business.registry.dao.CascadableDao
import com.business.registry.model.Auditable
import com.business.registry.model.UserAccount
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

/**
 * Generic service that handles cascading deletes while preserving audit trails.
 *
 * <p>Before the parent entity and each of its children are deleted, every child record
 * is stamped with the supplied {@code lastUser} and {@code changeReason} so that the
 * audit log captures <em>who</em> triggered the deletion and <em>why</em>.
 *
 * <p>Usage example (inside CompanyService):
 * <pre>
 *   deleteService.cascadeDelete(
 *       company, user, changeReason,
 *       [
 *           new ChildGroup<Member>({ memberDao.findAllMembersByCompany(company) }, memberDao),
 *           new ChildGroup<CompanyStock>({ companyStockDao.findAllByCompanyId(company.id) }, companyStockDao),
 *           // … more child groups …
 *       ],
 *       { companyDao.deleteCompanyById(company.id) }
 *   )
 * </pre>
 */
@Service
@CompileStatic
class DeleteService {

    /**
     * Describes one group of child records that must be audited and deleted
     * before their parent is removed.
     *
     * <p>The {@link CascadableDao} supplies both the {@code save} and
     * {@code deleteById} operations, so callers only need to provide the
     * query that fetches the relevant children.
     *
     * @param <T> the child entity type – must implement {@link Auditable}
     */
    static class ChildGroup<T extends Auditable> {
        /** Returns all child records that belong to the parent being deleted. */
        final Closure<List<T>> fetchChildren

        /** DAO that knows how to persist and remove a child record. */
        final CascadableDao<T> dao

        ChildGroup(Closure<List<T>> fetchChildren, CascadableDao<T> dao) {
            this.fetchChildren = fetchChildren
            this.dao = dao
        }
    }

    /**
     * Stamps every child in every {@link ChildGroup} with {@code lastUser} /
     * {@code changeReason}, saves them, then deletes them, and finally deletes
     * the parent itself.
     *
     * <p>Everything runs inside the caller's transaction (the method is
     * {@code REQUIRED} by default, so it joins an existing one).
     *
     * @param parent        the parent entity being deleted – must implement {@link Auditable}
     * @param user          the {@link UserAccount} performing the deletion
     * @param changeReason  the reason recorded in the audit trail
     * @param childGroups   ordered list of child descriptors; children are processed
     *                      in list order, so put grandchildren before their parents
     *                      when there are nested FK dependencies
     * @param deleteParent  closure that physically removes the parent record
     */
    @Transactional
    void cascadeDelete(Auditable parent,
                              UserAccount user,
                              String changeReason,
                              List<ChildGroup> childGroups,
                              Closure<Void> deleteParent) {

        // 1. Stamp + delete every child group (in order)
        childGroups.each { ChildGroup group ->
            List<Auditable> children = group.fetchChildren.call() as List<Auditable>
            children.each { Auditable child ->
                child.lastUser = user
                child.changeReason = changeReason
                group.dao.saveAndFlush(child)
            }
            children.each { Auditable child ->
                group.dao.deleteById(child.id)
            }
        }

        // 2. Stamp the parent itself before removing it
        parent.lastUser = user
        parent.changeReason = changeReason

        // 3. Remove the parent
        deleteParent.call()
    }
}
