import { httpClient } from "src/shared/services/httpClient/httpClient";
import { AxiosResponse } from "axios";
import {
  LegalEntityRequestDto,
  LegalEntityResponseDto,
} from "src/pages/legalEntity/types";

export const indexLegalEntity = (): Promise<
  AxiosResponse<LegalEntityResponseDto[]>
> => httpClient.get("/api/legalEntity/index");

export const viewLegalEntity = (
  id: number,
): Promise<AxiosResponse<LegalEntityResponseDto>> =>
  httpClient.get(`/api/legalEntity/view/${id}`);

export const createLegalEntity = ({
  data,
}: {
  data: LegalEntityRequestDto;
}): Promise<AxiosResponse> => {
  return httpClient.post("/api/legalEntity/create", data);
};

export const updateLegalEntity = ({
  id,
  data,
}: {
  id: number;
  data: LegalEntityRequestDto;
}): Promise<AxiosResponse> => {
  return httpClient.put(`/api/legalEntity/update/${id}`, data);
};

export const deleteLegalEntity = ({
  id,
  changeReason,
}: {
  id: number;
  changeReason: string;
}): Promise<AxiosResponse> =>
  httpClient.delete(`/api/legalEntity/delete/${id}`, {
    data: {
      changeReason,
    },
  });
