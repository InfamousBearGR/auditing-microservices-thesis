import { httpClient } from "src/shared/services/httpClient/httpClient";
import { AxiosResponse } from "axios";
import { PersonRequestDto, PersonResponseDto } from "src/pages/person/types";

export const indexPerson = (): Promise<AxiosResponse<PersonResponseDto[]>> =>
  httpClient.get("/api/person/index");

export const viewPerson = (
  id: number,
): Promise<AxiosResponse<PersonResponseDto>> =>
  httpClient.get(`/api/person/view/${id}`);

export const createPerson = ({
  data,
}: {
  data: PersonRequestDto;
}): Promise<AxiosResponse> => {
  return httpClient.post("/api/person/create", data);
};

export const updatePerson = ({
  id,
  data,
}: {
  id: number;
  data: PersonRequestDto;
}): Promise<AxiosResponse> => {
  return httpClient.put(`/api/person/update/${id}`, data);
};

export const deletePerson = ({
  id,
  changeReason,
}: {
  id: number;
  changeReason: string;
}): Promise<AxiosResponse> =>
  httpClient.delete(`/api/person/delete/${id}`, {
    data: {
      changeReason,
    },
  });
