import axios from "axios";
import {i18n as I18nType} from "i18next";
import i18n from "src/shared/services/languages/i18n";
import {queryClient} from "src/shared/services/queryClient/reactQueryClient";
import {Dispatch, SetStateAction} from "react";

const httpClient = axios.create({
  baseURL: import.meta.env.VITE_APP_API_URL,
  withCredentials: true,
});

let responseInterceptorId: number | null = null;
let requestInterceptorId: number | null = null;

const configureHttpClient = (
  _i18n: I18nType | undefined,
  setUserCantAccess: Dispatch<SetStateAction<boolean>>,
) => {
  if (responseInterceptorId !== null) {
    httpClient.interceptors.response.eject(responseInterceptorId);
  }
  if (requestInterceptorId !== null) {
    httpClient.interceptors.request.eject(requestInterceptorId);
  }

  responseInterceptorId = httpClient.interceptors.response.use(
    (response) => {
      return response;
    },
    (error) => {
      if (
        (error?.response?.status == 502 || error?.response?.status == 503) &&
        window.location.pathname !== "/error502"
      ) {
        window.location.href = import.meta.env.VITE_APP_URL + "/error502";
        return Promise.reject({ ...error, response: { data: undefined } });
      } else if (error?.response?.status == 504) {
        let text = "Σφάλμα συστήματος, προσπαθήστε ξανά αργότερα.";
        if (localStorage.getItem("lng")) {
          switch (localStorage.getItem("lng")) {
            case "el":
              text = "Σφάλμα συστήματος, προσπαθήστε ξανά αργότερα.";
              break;
            case "en":
              text = "System error, try again later.";
              break;
            default:
              text = "Σφάλμα συστήματος, προσπαθήστε ξανά αργότερα.";
          }
        }
        return Promise.reject({ ...error, response: { data: text } });
      } else if (error?.response?.status == 401) {
        queryClient.invalidateQueries({ queryKey: ["checkUserSession"] });
      } else if (error?.response?.status == 403) {
        setUserCantAccess(true);
      }

      return Promise.reject(error);
    },
  );

  requestInterceptorId = httpClient.interceptors.request.use(
    (config) => {
      let language: string;
      switch (i18n?.language) {
        case "el":
          language = "el-GR";
          break;
        case "en":
          language = "en-US";
          break;
        default:
          language = "el-GR";
      }
      config.headers.set("Accept-Language", language);
      config.headers.set("Content-Type", "application/json");
      return config;
    },
    (error) => {
      return Promise.reject(error);
    },
  );
};
export { configureHttpClient, httpClient };
