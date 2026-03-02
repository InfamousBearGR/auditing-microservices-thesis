import i18n from "i18next";
import translationEl from "src/shared/services/languages/el/greek.json";
import translationEn from "src/shared/services/languages/en/english.json";
import { initReactI18next } from "react-i18next";
import { queryClient } from "src/shared/services/queryClient/reactQueryClient";

const langSelect = () => {
  if (localStorage.getItem("lng")) {
    return localStorage.getItem("lng")?.toString();
  } else {
    localStorage.setItem("lng", "el");
    return "el";
  }
};

const resources = {
  el: {
    translation: { ...translationEl },
  },
  en: {
    translation: { ...translationEn },
  },
};
i18n.on("languageChanged", () => {
  queryClient?.invalidateQueries();
});

i18n.use(initReactI18next).init({
  resources,
  debug: false,
  lng: langSelect(),
  fallbackLng: "el",
  keySeparator: "~",
  nsSeparator: "|",
});

export default i18n;
