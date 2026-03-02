import { httpClient } from "src/shared/services/httpClient";
import { AxiosResponse } from "axios";

type UserSessionResponse = {
  authenticated: boolean;
  username: string;
  role: number;
};

type LogoutResponse = {
  message: string;
};

export const checkUserSession = (): Promise<
  AxiosResponse<UserSessionResponse>
> => httpClient.get("/auth/status");

export const login = ({
  username,
  password,
}: {
  username: string;
  password: string;
}): Promise<AxiosResponse<UserSessionResponse>> => {
  return httpClient.post(
    "/auth/login",
    {
      username,
      password,
    },
    {
      withCredentials: true,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    },
  );
};

export const logout = (): Promise<AxiosResponse<LogoutResponse>> =>
  httpClient.post("/auth/logout");
