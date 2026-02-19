package com.business.registry.repository

import com.business.registry.model.Language
import com.business.registry.model.Prefecture
import com.business.registry.model.PrefectureI18n
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface PrefectureI18nRepository extends JpaRepository<PrefectureI18n, Long> {
    List<PrefectureI18n> findByPrefectureInAndLanguage(Collection<Prefecture> prefectures, Language language)

    PrefectureI18n findByPrefectureAndLanguage(Prefecture prefecture, Language language)
}
