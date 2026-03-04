package com.business.registry.dao

import com.business.registry.model.Company
import com.business.registry.model.Member
import com.business.registry.repository.MemberRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class MemberDao implements CascadableDao<Member> {

    private final MemberRepository memberRepository

    MemberDao(MemberRepository memberRepository) {
        this.memberRepository = memberRepository
    }

    Member findMemberById(Long id) {
        return memberRepository.findById(id).orElse(null)
    }

    List<Member> findAllMembersByCompany(Company company) {
        return memberRepository.findAllByCompany(company)
    }

    boolean existsById(Long id) {
        return memberRepository.existsById(id)
    }

    @Override
    Member save(Member member) {
        return memberRepository.save(member)
    }

    @Override
    Member saveAndFlush(Member member) {
        return memberRepository.saveAndFlush(member)
    }

    @Override
    void deleteById(Long id) {
        memberRepository.deleteById(id)
    }
}
