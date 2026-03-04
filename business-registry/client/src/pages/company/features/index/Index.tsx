import { useTranslation } from "react-i18next";
import { Box, Typography } from "@mui/material";
import { useIndexCompany } from "src/pages/company/data-access/useIndexCompany";
import { enqueueSnackbar } from "notistack";
import { useMemo } from "react";
import { MaterialReactTable, MRT_ColumnDef } from "material-react-table";
import { CompanyResponseDto } from "src/pages/company/types";
import { useCustomMaterialTable } from "src/shared/hooks/useCustomMaterialTable";
import { getTableLang } from "src/shared/services/languages/MaterialReactTable/getTableLang";
import { TableActions } from "src/pages/company/features/index/components/TableActions";

export const Index = () => {
  const { t, i18n } = useTranslation();
  const { data, isLoading, isError } = useIndexCompany();

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση των επιχειρήσεων"), {
      variant: "error",
    });
  }

  const columns = useMemo<MRT_ColumnDef<CompanyResponseDto>[]>(
    () => [
      {
        header: t("Αριθμός Μητρώου"),
        accessorKey: "registryNumber",
      },
      {
        header: t("Επωνυμία"),
        accessorKey: "name",
      },
      {
        header: t("Νομική Μορφή"),
        accessorKey: "legalType.description",
      },
      {
        header: t("ΑΦΜ"),
        accessorKey: "afm",
      },
      {
        header: t("Κατάσταση"),
        accessorKey: "companyStatus.description",
      },
      {
        accessorKey: "actions",
        header: t("Ενέργειες"),
        Cell: ({ row }) => <TableActions row={row} />,
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
      isLoading: isLoading,
    },
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
      <Typography variant={"h6"}>{t("Ευρετήριο Επιχειρήσεων")}</Typography>
      <MaterialReactTable table={table} />
    </Box>
  );
};
