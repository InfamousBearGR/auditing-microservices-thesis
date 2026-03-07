import {useTranslation} from "react-i18next";
import {useNavigate, useParams} from "@tanstack/react-router";
import {useViewCompany} from "src/pages/company/data-access/useViewCompany";
import {enqueueSnackbar} from "notistack";
import {Box, Typography} from "@mui/material";
import {Details} from "src/shared/components/Details/Details";
import {stringToFormatDate} from "src/shared/utils";
import {CustomCircularProgressBar} from "src/shared/components/CustomCircularProgressBar";

export const View = () => {
  const { t } = useTranslation();
  const { id: idParam } = useParams({ from: "/company/view/$id" });
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

  const rows: { name: string; value: string }[] = [
    { name: t("Αριθμός Μητρώου"), value: data?.data?.registryNumber ?? "" },
    { name: t("Επωνυμία"), value: data?.data?.name ?? "" },
    { name: t("Νομική Μορφή"), value: data?.data?.legalType.description ?? "" },
    { name: t("ΑΦΜ"), value: data?.data?.afm ?? "" },
    {
      name: t("Κατάσταση Επιχείρησης"),
      value: data?.data?.companyStatus.description ?? "",
    },
    {
      name: t("Ημερομηνία Ίδρυσης"),
      value: stringToFormatDate(data?.data?.dateIncorporated) ?? "",
    },
    {
      name: t("Χώρα"),
      value: data?.data?.country.description ?? "",
    },
    {
      name: t("Περιφέρεια"),
      value: data?.data?.region.description ?? "",
    },
    {
      name: t("Νομός"),
      value: data?.data?.prefecture.description ?? "",
    },
    {
      name: t("Δήμος"),
      value: data?.data?.municipality.description ?? "",
    },
    {
      name: t("Πόλη"),
      value: data?.data?.city ?? "",
    },
    {
      name: t("Οδός"),
      value: data?.data?.street ?? "",
    },
    {
      name: t("Αριθμός Οδού"),
      value: data?.data?.streetNumber ?? "",
    },
    {
      name: t("Ταχυδρομικός Κώδικας"),
      value: data?.data?.postalCode ?? "",
    },
  ];

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
        <>
          <Typography
            variant={"h5"}
          >{`${t("Επιχείρηση")}: ${data?.data?.registryNumber} ${data?.data?.name}`}</Typography>
          <Details rows={rows} />
        </>
      )}
    </Box>
  );
};
