import { useTranslation } from "react-i18next";
import { useNavigate, useParams } from "@tanstack/react-router";
import { useViewLegalEntity } from "src/pages/legalEntity/data-access/useViewLegalEntity";
import { enqueueSnackbar } from "notistack";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";
import { Box } from "@mui/system";
import { Button, Typography } from "@mui/material";
import { useUpdateLegalEntity } from "src/pages/legalEntity/data-access/useUpdateLegalEntity";
import {
  LegalEntityValidationSchema,
  getLegalEntityValidationSchema,
} from "src/pages/legalEntity/features/shared/validation/validationSchema";
import { zodResolver } from "@hookform/resolvers/zod";
import { FormContainer, useForm, UseFormReturn } from "react-hook-form-mui";
import { useEffect } from "react";
import EditIcon from "@mui/icons-material/Edit";
import { LegalEntityForm } from "src/pages/legalEntity/features/shared/LegalEntityForm";

export const Edit = () => {
  const { t } = useTranslation();
  const { id: idParam } = useParams({ from: "/legalEntity/edit/$id" });
  const navigate = useNavigate();

  const id = idParam ? Number(idParam) : undefined;

  if (!id) {
    navigate({ to: "/legalEntity/index" });
  }

  const { data, isLoading, isError } = useViewLegalEntity(id!);

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση του Νομικού Προσώπου"), {
      variant: "error",
    });
    navigate({ to: "/legalEntity/index" });
  }

  const { mutate, isPending } = useUpdateLegalEntity();

  const formContext: UseFormReturn<LegalEntityValidationSchema> = useForm({
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

  useEffect(() => {
    if (data?.data && !isLoading) {
      formContext.reset({
        registryNumber: data.data.registryNumber,
        businessName: data.data.businessName,
        afm: data.data.afm,
        phoneNumber: data.data.phoneNumber ?? "",
        city: data.data.city,
        street: data.data.street,
        streetNumber: data.data.streetNumber,
        postalCode: data.data.postalCode,
        countryId: data.data.country.id,
        prefectureId: data.data.prefecture.id,
        municipalityId: data.data.municipality.id,
        regionId: data.data.region.id,
        changeReason: "",
      });
    }
  }, [data?.data, formContext, isLoading]);

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        gap: "1rem",
        width: "100%",
      }}
    >
      {isLoading ? (
        <CustomCircularProgressBar />
      ) : (
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: "1rem",
            width: "100%",
          }}
        >
          <Typography
            variant={"h5"}
          >{`${t("Επεξεργασία Νομικού Προσώπου")}: ${data?.data?.registryNumber} ${data?.data?.businessName}`}</Typography>
          <FormContainer
            formContext={formContext}
            onSuccess={(data) =>
              mutate({
                id: id!,
                data: data,
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
      )}
    </Box>
  );
};
