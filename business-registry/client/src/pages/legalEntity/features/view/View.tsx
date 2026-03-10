import { useTranslation } from "react-i18next";
import { useNavigate, useParams } from "@tanstack/react-router";
import { useViewLegalEntity } from "src/pages/legalEntity/data-access/useViewLegalEntity";
import { enqueueSnackbar } from "notistack";
import { Box, Button, Typography } from "@mui/material";
import { Details } from "src/shared/components/Details/Details";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";
import EditIcon from "@mui/icons-material/Edit";

export const View = () => {
  const { t } = useTranslation();
  const { id: idParam } = useParams({ from: "/legalEntity/view/$id" });
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

  const rows: { name: string; value: string }[] = [
    { name: t("Αριθμός Μητρώου"), value: data?.data?.registryNumber ?? "" },
    {
      name: t("Επωνυμία Νομικού Προσώπου"),
      value: data?.data?.businessName ?? "",
    },
    { name: t("ΑΦΜ"), value: data?.data?.afm ?? "" },
    { name: t("Τηλέφωνο"), value: data?.data?.phoneNumber ?? "" },
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
          <Box
            sx={{
              display: "flex",
              flexDirection: "row",
              gap: "1rem",
              width: "100%",
              alignItems: "center",
            }}
          >
            <Typography
              variant={"h5"}
            >{`${t("Νομικό Πρόσωπο")}: ${data?.data?.registryNumber} ${data?.data?.businessName}`}</Typography>
            <Button
              onClick={() =>
                navigate({
                  to: "/legalEntity/edit/$id",
                  params: { id: idParam },
                })
              }
              startIcon={<EditIcon />}
              variant={"contained"}
            >
              {t("Επεξεργασία")}
            </Button>
          </Box>
          <Details rows={rows} />
        </>
      )}
    </Box>
  );
};
