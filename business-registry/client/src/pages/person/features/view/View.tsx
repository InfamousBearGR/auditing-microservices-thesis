import { useTranslation } from "react-i18next";
import { useNavigate, useParams } from "@tanstack/react-router";
import { useViewPerson } from "src/pages/person/data-access/useViewPerson";
import { enqueueSnackbar } from "notistack";
import { Box, Typography } from "@mui/material";
import { Details } from "src/shared/components/Details/Details";
import { stringToFormatDate } from "src/shared/utils";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";

export const View = () => {
  const { t } = useTranslation();
  const { id: idParam } = useParams({ from: "/person/view/$id" });
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

  const rows: { name: string; value: string }[] = [
    { name: t("Όνομα"), value: data?.data?.name ?? "" },
    { name: t("Επώνυμο"), value: data?.data?.surname ?? "" },
    { name: t("ΑΦΜ"), value: data?.data?.afm ?? "" },
    { name: t("Αριθμός Ταυτότητας"), value: data?.data?.identityNumber ?? "" },
    {
      name: t("Ημερομηνία Γέννησης"),
      value: stringToFormatDate(data?.data?.birthDate) ?? "",
    },
    { name: t("Τόπος Γέννησης"), value: data?.data?.birthPlace ?? "" },
    { name: t("Χώρα"), value: data?.data?.country.description ?? "" },
    { name: t("Περιφέρεια"), value: data?.data?.region.description ?? "" },
    { name: t("Νομός"), value: data?.data?.prefecture.description ?? "" },
    { name: t("Δήμος"), value: data?.data?.municipality.description ?? "" },
    { name: t("Πόλη"), value: data?.data?.city ?? "" },
    { name: t("Οδός"), value: data?.data?.street ?? "" },
    { name: t("Αριθμός Οδού"), value: data?.data?.streetNumber ?? "" },
    {
      name: t("Ταχυδρομικός Κώδικας"),
      value: data?.data?.postalCode ?? "",
    },
    { name: t("Τηλέφωνο"), value: data?.data?.phoneNumber ?? "" },
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
          >{`${t("Φυσικό Πρόσωπο")}: ${data?.data?.name} ${data?.data?.surname}`}</Typography>
          <Details rows={rows} />
        </>
      )}
    </Box>
  );
};
