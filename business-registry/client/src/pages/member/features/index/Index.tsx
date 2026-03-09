import { useTranslation } from "react-i18next";
import { useIndexMember } from "src/pages/member/data-access/useIndexMember";
import { useNavigate, useParams } from "@tanstack/react-router";
import { enqueueSnackbar } from "notistack";
import { useMemo } from "react";
import { MaterialReactTable, MRT_ColumnDef } from "material-react-table";
import { MemberResponseDto } from "src/pages/member/types";
import { TableActions } from "src/shared/components/TableActions";
import { useDeleteMember } from "src/pages/member/data-access/useDeleteMember";
import { useCustomMaterialTable } from "src/shared/hooks/useCustomMaterialTable";
import { getTableLang } from "src/shared/services/languages/MaterialReactTable/getTableLang";
import { Box, Button, Typography } from "@mui/material";
import ReplayIcon from "@mui/icons-material/Replay";
import { useQueryClient } from "@tanstack/react-query";
import PersonAddIcon from "@mui/icons-material/PersonAdd";
import { stringToFormatDate } from "src/shared/utils";

export const Index = () => {
  const { t, i18n } = useTranslation();
  const queryClient = useQueryClient();
  const { id: idParam } = useParams({
    from: "/company/$id/member/index",
  });
  const navigate = useNavigate();
  const id = idParam ? Number(idParam) : undefined;
  if (!id) {
    navigate({ to: "/company/index" });
  }
  const { data, isFetching, isError } = useIndexMember(id!);

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση των Εταίρων"), {
      variant: "error",
    });
  }

  const columns = useMemo<MRT_ColumnDef<MemberResponseDto>[]>(
    () => [
      {
        header: t("ΑΦΜ"),
        accessorKey: "afm",
        Cell: ({ row }) =>
          row.original.person?.afm ?? row.original.legalEntity?.afm ?? "",
      },
      {
        header: t("Ιδιότητα"),
        accessorKey: "memberRelation.description",
      },
      {
        header: t("Ενεργός"),
        accessorKey: "active",
        Cell: ({ row }) => (row.original.active ? t("Ναι") : t("Όχι")),
      },
      {
        header: t("Ημερομηνία Έναρξης"),
        accessorKey: "dateFrom",
        Cell: ({ row }) =>
          row.original.dateFrom
            ? stringToFormatDate(row.original.dateFrom)
            : "",
      },
      {
        header: t("Ημερομηνία Λήξης"),
        accessorKey: "dateTo",
        Cell: ({ row }) =>
          row.original.dateTo ? stringToFormatDate(row.original.dateTo) : "",
      },
      {
        header: t("Ποσοστό Ιδιοκτησίας"),
        accessorKey: "percentageOfOwnership",
      },
      {
        accessorKey: "actions",
        header: t("Ενέργειες"),
        enableColumnFilter: false,
        enableColumnActions: false,
        enableSorting: false,
        Cell: ({ row }) => (
          <TableActions
            id={row.original.id}
            name={
              row.original.person
                ? `${row.original.person.name} ${row.original.person.surname}`
                : (row.original.legalEntity?.businessName ?? "")
            }
            table={`company/${id}/member`}
            useMutation={useDeleteMember()}
            editTitle={t("Επεξεργασία Εταίρου")}
            viewTitle={t("Προβολή Εταίρου")}
            deleteTitle={t("Διαγραφή Εταίρου")}
            deleteDescription={t(
              "Είστε σίγουροι ότι θέλετε να διαγράψετε αυτόν τον Εταίρο",
            )}
          />
        ),
      },
    ],
    [i18n.language],
  );

  const table = useCustomMaterialTable({
    columns: columns,
    data: data?.data ?? [],
    localization: getTableLang(),
    rowCount: data?.data?.length ?? 0,
    state: {
      isLoading: isFetching,
    },
    renderTopToolbarCustomActions: () => (
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
          startIcon={<PersonAddIcon />}
          color={"primary"}
          variant={"contained"}
          onClick={() =>
            navigate({
              to: `/company/$id/member/add`,
              params: { id: String(id) },
            })
          }
        >
          {t("Εισαγωγή Εταίρου")}
        </Button>
        <Button
          color={"info"}
          onClick={() =>
            queryClient.invalidateQueries({ queryKey: ["indexMember"] })
          }
          startIcon={<ReplayIcon />}
          loading={isFetching}
          loadingPosition="start"
          variant="contained"
        >
          {t("Ανανέωση Αποτελεσμάτων")}
        </Button>
      </Box>
    ),
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
      <Typography variant={"h5"}>{t("Εταίροι Επιχείρησης")}</Typography>
      <MaterialReactTable table={table} />
    </Box>
  );
};
