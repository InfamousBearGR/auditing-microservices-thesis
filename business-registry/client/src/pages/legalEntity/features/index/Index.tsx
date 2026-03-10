import { useTranslation } from "react-i18next";
import { Box, Button, Typography } from "@mui/material";
import { useIndexLegalEntity } from "src/pages/legalEntity/data-access/useIndexLegalEntity";
import { enqueueSnackbar } from "notistack";
import { useMemo } from "react";
import { MaterialReactTable, MRT_ColumnDef } from "material-react-table";
import { LegalEntityResponseDto } from "src/pages/legalEntity/types";
import { useCustomMaterialTable } from "src/shared/hooks/useCustomMaterialTable";
import { getTableLang } from "src/shared/services/languages/MaterialReactTable/getTableLang";
import { useQueryClient } from "@tanstack/react-query";
import ReplayIcon from "@mui/icons-material/Replay";
import { useDeleteLegalEntity } from "src/pages/legalEntity/data-access/useDeleteLegalEntity";
import { useNavigate } from "@tanstack/react-router";
import { TableActions } from "src/shared/components/TableActions";
import BusinessIcon from "@mui/icons-material/Business";

export const Index = () => {
  const { t } = useTranslation();
  const { data, isError, isFetching } = useIndexLegalEntity();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση των Νομικών Προσώπων"), {
      variant: "error",
    });
  }

  const columns = useMemo<MRT_ColumnDef<LegalEntityResponseDto>[]>(
    () => [
      {
        header: t("Αριθμός Μητρώου"),
        accessorKey: "registryNumber",
      },
      {
        header: t("Επωνυμία Νομικού Προσώπου"),
        accessorKey: "businessName",
      },
      {
        header: t("ΑΦΜ"),
        accessorKey: "afm",
      },
      {
        header: t("Τηλέφωνο"),
        accessorKey: "phoneNumber",
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
            name={row.original.businessName}
            table={"legalEntity"}
            useMutation={useDeleteLegalEntity()}
            editTitle={t("Επεξεργασία Νομικού Προσώπου")}
            viewTitle={t("Προβολή Νομικού Προσώπου")}
            deleteTitle={t("Διαγραφή Νομικού Προσώπου")}
            deleteDescription={t(
              "Είστε σίγουροι ότι θέλετε να διαγράψετε αυτό το Νομικό Πρόσωπο",
            )}
          />
        ),
      },
    ],
    [t],
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
          startIcon={<BusinessIcon />}
          color={"primary"}
          variant={"contained"}
          onClick={() =>
            navigate({
              to: `/legalEntity/add`,
            })
          }
        >
          {t("Εισαγωγή Νομικού Προσώπου")}
        </Button>
        <Button
          color={"info"}
          onClick={() =>
            queryClient.invalidateQueries({ queryKey: ["indexLegalEntity"] })
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
      <Typography variant={"h5"}>{t("Ευρετήριο Νομικών Προσώπων")}</Typography>
      <MaterialReactTable table={table} />
    </Box>
  );
};
