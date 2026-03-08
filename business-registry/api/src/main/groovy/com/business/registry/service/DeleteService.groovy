package com.business.registry.service

import com.business.registry.model.Auditable
import com.business.registry.model.UserAccount
import groovy.transform.CompileStatic
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
class DeleteService {
    static class ChildGroup<T extends Auditable> {
        /** Returns all child records that belong to the parent being deleted. */
        final Closure<List<T>> fetchChildren

        /** Repository that knows how to persist and remove a child record. */
        final JpaRepository<T, Long> repository

        ChildGroup(Closure<List<T>> fetchChildren, JpaRepository<T, Long> repository) {
            this.fetchChildren = fetchChildren
            this.repository = repository
        }
    }

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
                group.repository.saveAndFlush(child)
            }
            children.each { Auditable child ->
                group.repository.deleteById(child.id)
            }
        }

        // 2. Stamp the parent itself before removing it
        parent.lastUser = user
        parent.changeReason = changeReason

        // 3. Remove the parent
        deleteParent.call()
    }
}
