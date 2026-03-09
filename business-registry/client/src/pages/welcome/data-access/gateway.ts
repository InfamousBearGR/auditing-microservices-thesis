import {AxiosResponse} from "axios";
import {UserSessionResponse} from "src/shared/types/types";
import {httpClient} from "src/shared/services/httpClient/httpClient";

export const login = ({
  username,
  password,
}: {
  username: string;
  password: string;
}): Promise<AxiosResponse<UserSessionResponse>> => {
  return httpClient.post(
    "/api/auth/login",
    {
      username,
      password,
    },
    {
      withCredentials: true,
    },
  );
};
