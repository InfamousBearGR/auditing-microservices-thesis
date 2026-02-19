package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto

/**
 * Generic interface for mapping I18n entities to ParametricDto
 * @param <T> The I18n entity type
 */
interface I18nMapper<T> {

    /**
     * Converts an I18n entity to a ParametricDto
     * @param i18nEntity The I18n entity to convert
     * @return A ParametricDto with id and description from the entity
     */
    ParametricDto toParametricDto(T i18nEntity)

    /**
     * Converts a collection of I18n entities to a list of ParametricDto
     * @param i18nEntities Collection of I18n entities to convert
     * @return List of ParametricDto objects
     */
    List<ParametricDto> toParametricDtoList(Collection<T> i18nEntities)
}

