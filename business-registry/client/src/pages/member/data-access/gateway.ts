import { httpClient } from "src/shared/services/httpClient/httpClient";
import { AxiosResponse } from "axios";
import { MemberRequestDto, MemberResponseDto } from "src/pages/member/types";
import { ParametricDto } from "src/shared/types/types";

export const indexMember = (
  companyId: number,
): Promise<AxiosResponse<MemberResponseDto[]>> =>
  httpClient.get(`/api/member/index/${companyId}`);

export const viewMember = (
  id: number,
): Promise<AxiosResponse<MemberResponseDto>> =>
  httpClient.get(`/api/member/view/${id}`);

export const createMember = ({
  data,
}: {
  data: MemberRequestDto;
}): Promise<AxiosResponse> => {
  return httpClient.post("/api/member/create", data);
};

export const updateMember = ({
  id,
  data,
}: {
  id: number;
  data: MemberRequestDto;
}): Promise<AxiosResponse> => {
  return httpClient.put(`/api/member/update/${id}`, data);
};

export const deleteMember = ({
  id,
  changeReason,
}: {
  id: number;
  changeReason: string;
}): Promise<AxiosResponse> =>
  httpClient.delete(`/api/member/delete/${id}`, {
    data: {
      changeReason,
    },
  });

export const searchPersons = (): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get(`/api/person/search`);

export const searchLegalEntities = (): Promise<
  AxiosResponse<ParametricDto[]>
> => httpClient.get(`/api/legalEntity/search`);
