import { useTranslation } from "react-i18next";
import { useNavigate, useParams } from "@tanstack/react-router";
import { useViewMember } from "src/pages/member/data-access/useViewMember";
import { enqueueSnackbar } from "notistack";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";
import { Box, Typography } from "@mui/material";
import { Details } from "src/shared/components/Details/Details";

export const View = () => {
  const { t } = useTranslation();
  const { id: idParam, memberId: memberIdParam } = useParams({
    from: "/company/$id/member/view/$memberId",
  });
  const navigate = useNavigate();

  const memberId = memberIdParam ? Number(memberIdParam) : undefined;

  if (!memberId) {
    navigate({ to: `/company/${idParam}/member/index` });
  }

  const { data, isLoading, isError } = useViewMember(memberId!);

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση του μέλους"), {
      variant: "error",
    });
    navigate({ to: `/company/${idParam}/member/index` });
  }

  const rows: { name: string; value: string }[] = [
    ...(data?.data?.person
      ? [
          { name: "header", value: t("Στοιχεία Φυσικού Προσώπου") },
          { name: t("Όνομα"), value: data.data.person.name },
          { name: t("Επώνυμο"), value: data.data.person.surname },
          { name: t("ΑΦΜ"), value: data.data.person.afm },
        ]
      : []),
    ...(data?.data?.legalEntity
      ? [
          { name: "header", value: t("Στοιχεία Νομικού Προσώπου") },
          { name: t("Επωνυμία"), value: data.data.legalEntity.businessName },
          { name: t("ΑΦΜ"), value: data.data.legalEntity.afm },
        ]
      : []),
    { name: t("Ενεργός"), value: data?.data?.active ? t("Ναι") : t("Όχι") },
    {
      name: t("Ιδιότητα"),
      value: data?.data?.memberRelation.description ?? "",
    },
    { name: t("Ημερομηνία Έναρξης"), value: data?.data?.dateFrom ?? "" },
    { name: t("Ημερομηνία Λήξης"), value: data?.data?.dateTo ?? "" },
    {
      name: t("Ποσοστό Ιδιοκτησίας"),
      value: data?.data?.percentageOfOwnership ?? "",
    },
    {
      name: t("Μεμονομένη Εκπροσώπηση"),
      value: data?.data?.representedIndividual ? t("Ναι") : t("Όχι"),
    },
    {
      name: t("Απο Κοινού Εκπροσώπηση"),
      value: data?.data?.representedTogether ? t("Ναι") : t("Όχι"),
    },
    ...(data?.data?.representativeOfMember
      ? [
          { name: "header", value: t("Στοιχεία Εκπροσώπου Εταίρου") },
          { name: t("Όνομα"), value: data.data.representativeOfMember.name },
          {
            name: t("Επώνυμο"),
            value: data.data.representativeOfMember.surname,
          },
          { name: t("ΑΦΜ"), value: data.data.representativeOfMember.afm },
        ]
      : []),
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
          <Typography variant={"h5"}>{`${t("Εταίρος")}`}</Typography>
          <Details rows={rows} />
        </>
      )}
    </Box>
  );
};
