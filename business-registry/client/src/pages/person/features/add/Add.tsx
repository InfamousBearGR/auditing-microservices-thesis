import { useTranslation } from "react-i18next";
import { FormContainer, useForm } from "react-hook-form-mui";
import { zodResolver } from "@hookform/resolvers/zod";
import { getPersonValidationSchema } from "src/pages/person/features/shared/validation/validationSchema";
import { useCreatePerson } from "src/pages/person/data-access/useCreatePerson";
import { Box } from "@mui/system";
import { Button, Typography } from "@mui/material";
import { dateToString } from "src/shared/utils";
import { PersonForm } from "src/pages/person/features/shared/PersonForm";
import EditIcon from "@mui/icons-material/Edit";

export const Add = () => {
  const { t } = useTranslation();
  const { mutate, isPending } = useCreatePerson();

  const formContext = useForm({
    resolver: zodResolver(getPersonValidationSchema(t)),
    defaultValues: {
      name: "",
      surname: "",
      afm: "",
      city: "",
      street: "",
      streetNumber: "",
      postalCode: "",
      birthDate: undefined,
      birthPlace: "",
      identityNumber: "",
      countryId: undefined,
      prefectureId: undefined,
      municipalityId: undefined,
      regionId: undefined,
      phoneNumber: "",
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
      <Typography variant={"h5"}>{t("Εισαγωγή Φυσικού Προσώπου")}</Typography>
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
                birthDate: dateToString(data.birthDate),
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
            <PersonForm />
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
