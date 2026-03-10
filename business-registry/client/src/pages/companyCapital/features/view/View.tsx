import { useTranslation } from "react-i18next";
import { useNavigate, useParams } from "@tanstack/react-router";
import { useViewCompanyCapital } from "src/pages/companyCapital/data-access/useViewCompanyCapital";
import { enqueueSnackbar } from "notistack";
import { useMemo } from "react";
import { MaterialReactTable, MRT_ColumnDef } from "material-react-table";
import { CompanyStockResponseDto } from "src/pages/companyCapital/types";
import { useCustomMaterialTable } from "src/shared/hooks/useCustomMaterialTable";
import { getTableLang } from "src/shared/services/languages/MaterialReactTable/getTableLang";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";
import { Box, Button, Typography } from "@mui/material";
import { Details } from "src/shared/components/Details/Details";
import EditIcon from "@mui/icons-material/Edit";

export const View = () => {
  const { t } = useTranslation();
  const { id: idParam } = useParams({ from: "/company/$id/capital/view" });
  const navigate = useNavigate();

  const id = idParam ? Number(idParam) : undefined;

  if (!id) {
    navigate({ to: "/company/$id/details", params: { id: idParam } });
  }

  const { data, isFetching, isError } = useViewCompanyCapital(id!);

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση του κεφαλαίου"), {
      variant: "error",
    });
    navigate({ to: "/company/$id/details", params: { id: idParam } });
  }

  const rows: { name: string; value: string }[] = [
    { name: t("Τρέχον Κεφάλαιο"), value: data?.data?.totalAmount ?? "" },
    { name: t("Νόμισμα"), value: data?.data?.currency.description ?? "" },
  ];

  const columns = useMemo<MRT_ColumnDef<CompanyStockResponseDto>[]>(
    () => [
      {
        accessorKey: "stockType.description",
        header: t("Είδος Μετοχών"),
      },
      {
        accessorKey: "amount",
        header: t("Μερίδιο/Μετοχές"),
      },
      {
        accessorKey: "nominalPrice",
        header: t("Ονομαστική Αξία"),
      },
    ],
    [t],
  );

  const table = useCustomMaterialTable({
    columns: columns,
    data: data?.data?.stocks ?? [],
    localization: getTableLang(),
    rowCount: data?.data?.stocks?.length ?? 0,
    state: {
      isLoading: isFetching,
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
      {isFetching ? (
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
          <Box
            sx={{
              display: "flex",
              flexDirection: "row",
              gap: "1rem",
              width: "100%",
              alignItems: "center",
            }}
          >
            <Typography variant={"h5"}>{t("Κεφάλαιο και Μετοχές")}</Typography>
            <Button
              onClick={() =>
                navigate({
                  to: "/company/$id/capital/edit",
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
          <MaterialReactTable table={table} />
        </Box>
      )}
    </Box>
  );
};
