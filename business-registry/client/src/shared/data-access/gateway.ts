import { httpClient } from "src/shared/services/httpClient/httpClient";
import { AxiosResponse } from "axios";
import { ParametricDto, UserSessionResponse } from "src/shared/types/types";

type LogoutResponse = {
  message: string;
};

export const checkUserSession = (): Promise<
  AxiosResponse<UserSessionResponse>
> => httpClient.get("/api/auth/status");

export const logout = (): Promise<AxiosResponse<LogoutResponse>> =>
  httpClient.post("/api/auth/logout");

export const getCompanyStatuses = (): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get("/api/companyStatus/translations");

export const getCountries = (): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get("/api/country/translations");

export const getCurrencies = (): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get("/api/currency/translations");

export const getLegalTypes = (): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get("/api/legalType/translations");

export const getMemberRelations = (): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get("/api/memberRelation/translations");

export const getMunicipalities = (
  prefectureId: number,
): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get(`/api/municipality/translations/${prefectureId}`);

export const getPrefectures = (
  regionId: number,
): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get(`/api/prefecture/translations${regionId}`);

export const getRegions = (): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get("/api/region/translations");

export const getStockTypes = (): Promise<AxiosResponse<ParametricDto[]>> =>
  httpClient.get("/api/stockType/translations");
