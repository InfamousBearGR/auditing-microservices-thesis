import {ParametricDto} from "src/shared/types/types";

export type CompanyRequestDto = {
  name: string;
  city: string;
  street: string;
  countryId: number;
  prefectureId: number;
  municipalityId: number;
  streetNumber: string;
  regionId: number;
  postalCode: string;
  afm: string;
  legalTypeId: number;
  dateIncorporated: string;
  registryNumber: string;
  companyStatusId: number;
  changeReason: string;
};

export type CompanyResponseDto = {
  id: number;
  name: string;
  city: string;
  street: string;
  country: ParametricDto;
  prefecture: ParametricDto;
  municipality: ParametricDto;
  streetNumber: string;
  region: ParametricDto;
  postalCode: string;
  afm: string;
  legalType: ParametricDto;
  dateIncorporated: string;
  registryNumber: string;
  companyStatus: ParametricDto;
};
