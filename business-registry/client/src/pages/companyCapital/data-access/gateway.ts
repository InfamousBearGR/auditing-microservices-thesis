import { httpClient } from "src/shared/services/httpClient/httpClient";
import { AxiosResponse } from "axios";
import {
  CompanyCapitalRequestDto,
  CompanyCapitalResponseDto,
} from "src/pages/companyCapital/types";

export const viewCompanyCapital = (
  id: number,
): Promise<AxiosResponse<CompanyCapitalResponseDto>> =>
  httpClient.get(`/api/capital/view/${id}`);

export const updateCompanyCapital = ({
  data,
}: {
  data: CompanyCapitalRequestDto;
}): Promise<AxiosResponse> => httpClient.put("/api/capital/update", data);
