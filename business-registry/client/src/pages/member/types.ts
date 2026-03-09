import { ParametricDto } from "src/shared/types/types";

export type PersonDto = {
  id: number;
  name: string;
  surname: string;
  afm: string;
};

export type LegalEntityDto = {
  id: number;
  businessName: string;
  afm: string;
};

export type MemberRequestDto = {
  active: boolean;
  dateFrom: string;
  dateTo: string;
  percentageOfOwnership: string;
  personId: number | null;
  legalEntityId: number | null;
  companyId: number;
  representativeOfMemberId: number | null;
  representedIndividual: boolean;
  representedTogether: boolean;
  memberRelationId: number;
  changeReason: string;
};

export type MemberResponseDto = {
  id: number;
  active: boolean;
  dateFrom: string;
  dateTo: string;
  percentageOfOwnership: string;
  person: PersonDto | null;
  legalEntity: LegalEntityDto | null;
  representativeOfMember: PersonDto | null;
  representedIndividual: boolean;
  representedTogether: boolean;
  memberRelation: ParametricDto;
};
