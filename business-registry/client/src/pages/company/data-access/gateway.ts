import { httpClient } from "src/shared/services/httpClient/httpClient";
import { AxiosResponse } from "axios";
import { CompanyRequestDto, CompanyResponseDto } from "src/pages/company/types";

export const indexCompany = (
  companyStatusId?: number,
  legalTypeId?: number,
): Promise<AxiosResponse<CompanyResponseDto[]>> =>
  httpClient.get("/api/company/index", {
    params: {
      companyStatusId,
      legalTypeId,
    },
  });

export const viewCompany = (
  id: number,
): Promise<AxiosResponse<CompanyResponseDto>> =>
  httpClient.get(`/api/company/view/${id}`);

export const createCompany = ({
  data,
}: {
  data: CompanyRequestDto;
}): Promise<AxiosResponse> => {
  return httpClient.post("/api/company/create", data);
};

export const updateCompany = ({
  id,
  data,
}: {
  id: number;
  data: CompanyRequestDto;
}): Promise<AxiosResponse> => {
  return httpClient.put(`/api/company/update/${id}`, data);
};

export const deleteCompany = ({
  id,
  changeReason,
}: {
  id: number;
  changeReason: string;
}): Promise<AxiosResponse> =>
  httpClient.delete(`/api/company/delete/${id}`, {
    data: {
      changeReason,
    },
  });
