package com.business.registry.dao

import com.business.registry.model.UserAccount
import com.business.registry.repository.UserAccountRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class UserAccountDao {

    private final UserAccountRepository userAccountRepository

    UserAccountDao(UserAccountRepository userAccountRepository) {
        this.userAccountRepository = userAccountRepository
    }

    Optional<UserAccount> findByUsername(String username) {
        return userAccountRepository.findByUsername(username)
    }

    boolean existsByUsername(String username) {
        return userAccountRepository.existsByUsername(username)
    }

    Optional<UserAccount> findById(Long id) {
        return userAccountRepository.findById(id)
    }
}

