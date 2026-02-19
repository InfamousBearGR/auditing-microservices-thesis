package com.business.registry.repository

import com.business.registry.model.Role
import groovy.transform.CompileStatic
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
@CompileStatic
interface RoleRepository extends JpaRepository<Role, Long> {

    Optional<Role> findByDescription(String description)
}
