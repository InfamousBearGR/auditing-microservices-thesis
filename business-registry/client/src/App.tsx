import {createTheme, ThemeProvider} from "@mui/material";
import {elGR as coreGR, enUS as coreEn} from "@mui/material/locale";
import {elGR as DataGridGreek, enUS as DataGridEnglish,} from "@mui/x-data-grid/locales";
import {elGR as pickersGR, enUS as pickersEn,} from "@mui/x-date-pickers/locales";
import {AdapterDateFns} from "@mui/x-date-pickers/AdapterDateFns";
import {el} from "date-fns/locale/el";
import {enUS} from "date-fns/locale/en-US";
import {I18nextProvider, useTranslation} from "react-i18next";
import {queryClient} from "src/shared/services/queryClient/reactQueryClient";
import "src/shared/services/languages/i18n";
import {AuthProvider, useAuth} from "src/shared/context/useAuth";
import {configureHttpClient} from "src/shared/services/httpClient/httpClient";
import "@mui/material/Button";
import "@mui/material/Chip";
import {QueryClientProvider} from "@tanstack/react-query";
import {RouterProvider} from "@tanstack/react-router";
import {LocalizationProvider} from "@mui/x-date-pickers";
import MySnackbarProvider from "src/shared/services/snackbarProvider/snackbarProvider";
import {router} from "src/routes/router";
import {useEffect} from "react";

const ConfigurationContextComponent = () => {
  const { i18n } = useTranslation();
  const { setUserCantAccess } = useAuth();

  useEffect(() => {
    configureHttpClient(i18n, setUserCantAccess);
  }, []);

  return <></>;
};
type SupportedLanguage = "el" | "en";
const muiLanguagePacks: Record<SupportedLanguage, object[]> = {
  el: [DataGridGreek, pickersGR, coreGR],
  en: [DataGridEnglish, pickersEn, coreEn],
};
const muiDatePickersLangs = {
  el: el,
  en: enUS,
};
const muiLocaleTextLanguages: Record<SupportedLanguage, object> = {
  el: {
    ...pickersEn.components.MuiLocalizationProvider.defaultProps.localeText,
  },
  en: pickersEn.components.MuiLocalizationProvider.defaultProps.localeText,
};

const App = () => {
  const { i18n } = useTranslation();
  const theme = createTheme(
    {
      palette: {
        primary: {
          main: "#1526c0",
        },
      },
      typography: {
        button: {
          textTransform: "none",
        },
      },
      components: {
        MuiTextField: {
          styleOverrides: {
            root: {
              "&.Mui-disabled, &.MuiInputBase-readOnly": {
                backgroundColor: "#E8EBEE",
              },
            },
          },
        },
        MuiInputBase: {
          styleOverrides: {
            root: {
              "&.Mui-disabled, &.MuiInputBase-readOnly": {
                backgroundColor: "#E8EBEE",
                "& .MuiInputBase-input": {
                  WebkitTextFillColor: "#000000",
                  color: "#000000",
                },
              },
            },
          },
        },
      },
    },
    ...muiLanguagePacks[(i18n.language as SupportedLanguage) ?? "el"],
  );
  return (
    <>
      <QueryClientProvider client={queryClient}>
        <AuthProvider>
          <LocalizationProvider
            dateAdapter={AdapterDateFns}
            adapterLocale={
              muiDatePickersLangs[i18n.language as SupportedLanguage]
            }
            localeText={
              muiLocaleTextLanguages[i18n.language as SupportedLanguage]
            }
          >
            <I18nextProvider i18n={i18n}>
              <ThemeProvider theme={theme}>
                <MySnackbarProvider>
                  <ConfigurationContextComponent />
                  <RouterProvider router={router} />
                </MySnackbarProvider>
              </ThemeProvider>
            </I18nextProvider>
          </LocalizationProvider>
        </AuthProvider>
      </QueryClientProvider>
    </>
  );
};

export default App;
