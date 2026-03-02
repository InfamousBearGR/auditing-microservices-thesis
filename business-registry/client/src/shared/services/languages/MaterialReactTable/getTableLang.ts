import type { MRT_Localization } from "material-react-table";
import i18n from "src/shared/services/languages/i18n";
import el from "src/shared/services/languages/MaterialReactTable/el";
import { MRT_Localization_EN } from "material-react-table/locales/en";

const langMapper: Record<string, MRT_Localization> = {
  el: el as MRT_Localization,
  en: MRT_Localization_EN,
};

export default function getTableLang(): MRT_Localization {
  const currentLang = i18n.language;
  return langMapper[currentLang] || MRT_Localization_EN;
}
