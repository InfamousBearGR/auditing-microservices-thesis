import {useTranslation} from "react-i18next";
import {useNavigate, useParams} from "@tanstack/react-router";
import {useViewCompany} from "src/pages/company/data-access/useViewCompany";
import {enqueueSnackbar} from "notistack";
import {CustomCircularProgressBar} from "src/shared/components/CustomCircularProgressBar";
import {Box} from "@mui/system";
import {Button, Typography} from "@mui/material";
import {useUpdateCompany} from "src/pages/company/data-access/useUpdateCompany";
import {
  CompanyValidationSchema,
  getCompanyValidationSchema,
} from "src/pages/company/features/shared/validation/validationSchema";
import {zodResolver} from "@hookform/resolvers/zod";
import {FormContainer, useForm, UseFormReturn} from "react-hook-form-mui";
import {useEffect} from "react";
import EditIcon from "@mui/icons-material/Edit";
import {CompanyForm} from "src/pages/company/features/shared/CompanyForm";
import {dateToString, stringToDate} from "src/shared/utils";

export const Edit = () => {
  const { t } = useTranslation();
  const { id: idParam } = useParams({ from: "/company/edit/$id" });
  const navigate = useNavigate();

  const id = idParam ? Number(idParam) : undefined;

  if (!id) {
    navigate({ to: "/company/index" });
  }

  const { data, isLoading, isError } = useViewCompany(id!);

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση της επιχείρησης"), {
      variant: "error",
    });
    navigate({ to: "/company/index" });
  }

  const { mutate, isPending } = useUpdateCompany();

  const formContext: UseFormReturn<CompanyValidationSchema> = useForm({
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

  useEffect(() => {
    if (data?.data && !isLoading) {
      formContext.reset({
        name: data.data.name,
        city: data.data.city,
        street: data.data.street,
        streetNumber: data.data.streetNumber,
        postalCode: data.data.postalCode,
        afm: data.data.afm,
        dateIncorporated: stringToDate(data.data.dateIncorporated),
        registryNumber: data.data.registryNumber,
        countryId: data.data.country.id,
        prefectureId: data.data.prefecture.id,
        municipalityId: data.data.municipality.id,
        regionId: data.data.region.id,
        legalTypeId: data.data.legalType.id,
        companyStatusId: data.data.companyStatus.id,
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
          >{`${t("Επεξεργασία Επιχείρησης")}: ${data?.data?.registryNumber} ${data?.data?.name}`}</Typography>
          <FormContainer
            formContext={formContext}
            onSuccess={(data) =>
              mutate({
                id: id!,
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
      )}
    </Box>
  );
};
