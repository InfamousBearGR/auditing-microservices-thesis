import axios from "axios";
import { useTranslation } from "react-i18next";
import { queryClient } from "src/shared/services/queryClient/reactQueryClient";
import { useAuth } from "src/shared/context/useAuth";

const httpClient = axios.create({
  baseURL: import.meta.env.VITE_APP_API_URL,
  withCredentials: true,
});

const configureHttpClient = () => {
  const { i18n } = useTranslation();
  const { setUserCantAccess } = useAuth();

  httpClient.interceptors.response.use(
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

  httpClient.interceptors.request.use(
    (config) => {
      config.params = { ...config.params, lang: i18n?.language ?? "el" };

      return config;
    },
    (error) => {
      return Promise.reject(error);
    },
  );
};
export { configureHttpClient, httpClient };
