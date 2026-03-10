import { useTranslation } from "react-i18next";
import { useNavigate, useParams } from "@tanstack/react-router";
import { useViewPerson } from "src/pages/person/data-access/useViewPerson";
import { enqueueSnackbar } from "notistack";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";
import { Box } from "@mui/system";
import { Button, Typography } from "@mui/material";
import { useUpdatePerson } from "src/pages/person/data-access/useUpdatePerson";
import {
  getPersonValidationSchema,
  PersonValidationSchema,
} from "src/pages/person/features/shared/validation/validationSchema";
import { zodResolver } from "@hookform/resolvers/zod";
import { FormContainer, useForm, UseFormReturn } from "react-hook-form-mui";
import { useEffect } from "react";
import EditIcon from "@mui/icons-material/Edit";
import { PersonForm } from "src/pages/person/features/shared/PersonForm";
import { dateToString, stringToDate } from "src/shared/utils";

export const Edit = () => {
  const { t } = useTranslation();
  const { id: idParam } = useParams({ from: "/person/edit/$id" });
  const navigate = useNavigate();

  const id = idParam ? Number(idParam) : undefined;

  if (!id) {
    navigate({ to: "/person/index" });
  }

  const { data, isLoading, isError } = useViewPerson(id!);

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση του Φυσικού Προσώπου"), {
      variant: "error",
    });
    navigate({ to: "/person/index" });
  }

  const { mutate, isPending } = useUpdatePerson();

  const formContext: UseFormReturn<PersonValidationSchema> = useForm({
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
      changeReason: "",
    },
  });

  useEffect(() => {
    if (data?.data && !isLoading) {
      formContext.reset({
        name: data.data.name,
        surname: data.data.surname,
        afm: data.data.afm,
        city: data.data.city,
        street: data.data.street,
        streetNumber: data.data.streetNumber,
        postalCode: data.data.postalCode,
        birthDate: stringToDate(data.data.birthDate),
        birthPlace: data.data.birthPlace,
        identityNumber: data.data.identityNumber,
        countryId: data.data.country.id,
        prefectureId: data.data.prefecture.id,
        municipalityId: data.data.municipality.id,
        regionId: data.data.region.id,
        phoneNumber: data.data.phoneNumber,
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
          >{`${t("Επεξεργασία Φυσικού Προσώπου")}: ${data?.data?.name} ${data?.data?.surname}`}</Typography>
          <FormContainer
            formContext={formContext}
            onSuccess={(data) =>
              mutate({
                id: id!,
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
      )}
    </Box>
  );
};
