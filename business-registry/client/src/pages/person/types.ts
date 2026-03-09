import { ParametricDto } from "src/shared/types/types";

export type PersonRequestDto = {
  name: string;
  surname: string;
  afm: string;
  city: string;
  street: string;
  countryId: number;
  prefectureId: number;
  municipalityId: number;
  streetNumber: string;
  regionId: number;
  postalCode: string;
  birthDate: string;
  birthPlace: string;
  identityNumber: string;
  phoneNumber: string;
  changeReason: string;
};

export type PersonResponseDto = {
  id: number;
  name: string;
  surname: string;
  afm: string;
  city: string;
  street: string;
  country: ParametricDto;
  prefecture: ParametricDto;
  municipality: ParametricDto;
  streetNumber: string;
  region: ParametricDto;
  postalCode: string;
  birthDate: string;
  birthPlace: string;
  identityNumber: string;
  phoneNumber: string;
  changeReason: string;
};
