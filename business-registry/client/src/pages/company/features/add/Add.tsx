import {useTranslation} from "react-i18next";
import {FormContainer, useForm} from "react-hook-form-mui";
import {zodResolver} from "@hookform/resolvers/zod";
import {getCompanyValidationSchema} from "src/pages/company/features/shared/validation/validationSchema";
import {useCreateCompany} from "src/pages/company/data-access/useCreateCompany";
import {Box} from "@mui/system";
import {Button, Typography} from "@mui/material";
import {dateToString} from "src/shared/utils";
import {CompanyForm} from "src/pages/company/features/shared/CompanyForm";
import EditIcon from "@mui/icons-material/Edit";

export const Add = () => {
  const { t } = useTranslation();
  const { mutate, isPending } = useCreateCompany();

  const formContext = useForm({
    resolver: zodResolver(getCompanyValidationSchema(t)),
    defaultValues: {
      name: "",
      city: "",
      street: "",
      streetNumber: "",
      postalCode: "",
      afm: "",
      dateIncorporated: undefined,
      registryNumber: "",
      countryId: undefined,
      prefectureId: undefined,
      municipalityId: undefined,
      regionId: undefined,
      legalTypeId: undefined,
      companyStatusId: undefined,
      changeReason: "",
    },
  });

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        gap: "1rem",
        width: "100%",
      }}
    >
      <Typography variant={"h5"}>{t("Εισαγωγή Επιχείρησης")}</Typography>
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          gap: "1rem",
          width: "100%",
        }}
      >
        <FormContainer
          formContext={formContext}
          onSuccess={(data) =>
            mutate({
              data: {
                ...data,
                dateIncorporated: dateToString(data.dateIncorporated),
              },
            })
          }
        >
          <Box
            sx={{
              display: "flex",
              flexDirection: "column",
              gap: "1rem",
              width: "100%",
            }}
          >
            <CompanyForm />
            <Box
              sx={{
                display: "flex",
                flexDirection: "row",
                gap: "1rem",
                width: "100%",
                justifyContent: "flex-end",
              }}
            >
              <Button
                startIcon={<EditIcon />}
                variant={"contained"}
                loading={isPending}
                type={"submit"}
              >
                {t("Υποβολή")}
              </Button>
            </Box>
          </Box>
        </FormContainer>
      </Box>
    </Box>
  );
};
