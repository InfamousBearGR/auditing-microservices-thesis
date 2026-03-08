package com.business.registry.repository

import com.business.registry.model.StockType
import org.springframework.data.jpa.repository.JpaRepository

interface StockTypeRepository extends JpaRepository<StockType, Long> {
}