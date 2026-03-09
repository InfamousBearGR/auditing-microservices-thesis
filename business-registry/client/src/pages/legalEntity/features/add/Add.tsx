import { useTranslation } from "react-i18next";
import { FormContainer, useForm } from "react-hook-form-mui";
import { zodResolver } from "@hookform/resolvers/zod";
import { getLegalEntityValidationSchema } from "src/pages/legalEntity/features/shared/validation/validationSchema";
import { useCreateLegalEntity } from "src/pages/legalEntity/data-access/useCreateLegalEntity";
import { Box } from "@mui/system";
import { Button, Typography } from "@mui/material";
import { LegalEntityForm } from "src/pages/legalEntity/features/shared/LegalEntityForm";
import EditIcon from "@mui/icons-material/Edit";

export const Add = () => {
  const { t } = useTranslation();
  const { mutate, isPending } = useCreateLegalEntity();

  const formContext = useForm({
    resolver: zodResolver(getLegalEntityValidationSchema(t)),
    defaultValues: {
      registryNumber: "",
      businessName: "",
      afm: "",
      phoneNumber: "",
      city: "",
      street: "",
      streetNumber: "",
      postalCode: "",
      countryId: undefined,
      prefectureId: undefined,
      municipalityId: undefined,
      regionId: undefined,
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
      <Typography variant={"h5"}>{t("Εισαγωγή Νομικού Προσώπου")}</Typography>
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
          onSuccess={(data) => mutate({ data })}
        >
          <Box
            sx={{
              display: "flex",
              flexDirection: "column",
              gap: "1rem",
              width: "100%",
            }}
          >
            <LegalEntityForm />
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
