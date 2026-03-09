import { ParametricDto } from "src/shared/types/types";

export type LegalEntityRequestDto = {
  registryNumber: string;
  businessName: string;
  phoneNumber: string;
  afm: string;
  city: string;
  street: string;
  countryId: number;
  prefectureId: number;
  municipalityId: number;
  streetNumber: string;
  regionId: number;
  postalCode: string;
  changeReason: string;
};

export type LegalEntityResponseDto = {
  id: number;
  registryNumber: string;
  businessName: string;
  phoneNumber: string;
  afm: string;
  city: string;
  street: string;
  country: ParametricDto;
  prefecture: ParametricDto;
  municipality: ParametricDto;
  streetNumber: string;
  region: ParametricDto;
  postalCode: string;
};
