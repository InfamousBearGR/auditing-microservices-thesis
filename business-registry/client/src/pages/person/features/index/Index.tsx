import { useTranslation } from "react-i18next";
import { Box, Button, Typography } from "@mui/material";
import { useIndexPerson } from "src/pages/person/data-access/useIndexPerson";
import { enqueueSnackbar } from "notistack";
import { useMemo } from "react";
import { MaterialReactTable, MRT_ColumnDef } from "material-react-table";
import { PersonResponseDto } from "src/pages/person/types";
import { useCustomMaterialTable } from "src/shared/hooks/useCustomMaterialTable";
import { getTableLang } from "src/shared/services/languages/MaterialReactTable/getTableLang";
import { useQueryClient } from "@tanstack/react-query";
import ReplayIcon from "@mui/icons-material/Replay";
import { useDeletePerson } from "src/pages/person/data-access/useDeletePerson";
import PersonAddIcon from "@mui/icons-material/PersonAdd";
import { useNavigate } from "@tanstack/react-router";
import { TableActions } from "src/shared/components/TableActions";

export const Index = () => {
  const { t, i18n } = useTranslation();
  const { data, isError, isFetching } = useIndexPerson();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση των Φυσικών Προσώπων"), {
      variant: "error",
    });
  }

  const columns = useMemo<MRT_ColumnDef<PersonResponseDto>[]>(
    () => [
      {
        header: t("Όνομα"),
        accessorKey: "name",
      },
      {
        header: t("Επώνυμο"),
        accessorKey: "surname",
      },
      {
        header: t("ΑΦΜ"),
        accessorKey: "afm",
      },
      {
        header: t("Αριθμός Ταυτότητας"),
        accessorKey: "identityNumber",
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
            name={row.original.name}
            table={"person"}
            useMutation={useDeletePerson()}
            editTitle={t("Επεξεργασία Φυσικού Προσώπου")}
            viewTitle={t("Προβολή Φυσικού Προσώπου")}
            deleteTitle={t("Διαγραφή Φυσικού Προσώπου")}
            deleteDescription={t(
              "Είστε σίγουροι ότι θέλετε να διαγράψετε αυτό το Φυσικό Πρόσωπο",
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
              to: `/person/add`,
            })
          }
        >
          {t("Εισαγωγή Φυσικού Προσώπου")}
        </Button>
        <Button
          color={"info"}
          onClick={() =>
            queryClient.invalidateQueries({ queryKey: ["indexPerson"] })
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
      <Typography variant={"h5"}>{t("Ευρετήριο Φυσικών Προσώπων")}</Typography>
      <MaterialReactTable table={table} />
    </Box>
  );
};
