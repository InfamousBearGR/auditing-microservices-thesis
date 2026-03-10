import { ParametricDto } from "src/shared/types/types";

export type CompanyStockRequestDto = {
  id?: number | undefined;
  companyId: number;
  stockTypeId: number;
  amount: number;
  nominalPrice: string;
  toBeDeleted: boolean;
};

export type CompanyStockResponseDto = {
  id: number;
  companyId: number;
  amount: number;
  stockType: ParametricDto;
  nominalPrice: number;
};

export type CompanyCapitalRequestDto = {
  companyId: number;
  totalAmount: string;
  currencyId: number;
  changeReason: string;
  stocks: CompanyStockRequestDto[];
};

export type CompanyCapitalResponseDto = {
  companyId: number;
  totalAmount: string;
  currency: ParametricDto;
  stocks: CompanyStockResponseDto[];
};
