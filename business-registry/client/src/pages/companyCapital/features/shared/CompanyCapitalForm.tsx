import { useTranslation } from "react-i18next";
import {
  TextFieldElement,
  useFieldArray,
  useFormContext,
  UseFormReturn,
} from "react-hook-form-mui";
import {
  CompanyCapitalValidationSchema,
  CompanyStockValidationSchema,
} from "src/pages/companyCapital/features/shared/validation/validationSchema";
import { Box, Button } from "@mui/material";
import { CurrencyAutocomplete } from "src/shared/components/CurrencyAutocomplete";
import { useCustomMaterialTable } from "src/shared/hooks/useCustomMaterialTable";
import { getTableLang } from "src/shared/services/languages/MaterialReactTable/getTableLang";
import { MaterialReactTable, MRT_ColumnDef } from "material-react-table";
import { useMemo, useState } from "react";
import AddIcon from "@mui/icons-material/Add";
import { useGetStockTypes } from "src/shared/data-access/useGetStockTypes";
import { EditAndAddStockModal } from "src/pages/companyCapital/features/shared/EditAndAddStockModal";
import { TableActionsForStocks } from "src/pages/companyCapital/features/shared/TableActionsForStocks";

type CompanyCapitalFormProps = {
  isFetching: boolean;
  companyId: number;
};

export const CompanyCapitalForm = (props: CompanyCapitalFormProps) => {
  const { isFetching, companyId } = props;
  const { t } = useTranslation();
  const formContext: UseFormReturn<CompanyCapitalValidationSchema> =
    useFormContext();
  const [openAddModal, setOpenAddModal] = useState<boolean>(false);

  const {
    fields: stocks,
    append: appendStock,
    update: updateStock,
  } = useFieldArray<CompanyCapitalValidationSchema, "stocks">({
    control: formContext.control,
    name: "stocks",
  });

  const { data: stockTypes, isFetching: isFetchingStockTypes } =
    useGetStockTypes();

  const columns = useMemo<MRT_ColumnDef<CompanyStockValidationSchema>[]>(
    () => [
      {
        accessorKey: "stockTypeId",
        header: t("Είδος Μετοχών"),
        Cell: ({ cell }) => {
          const stockTypeId = cell.getValue() as number;
          const stockType = stockTypes?.data?.find(
            (type) => type.id === stockTypeId,
          );
          return stockType ? stockType.description : "";
        },
      },
      {
        accessorKey: "amount",
        header: t("Μερίδιο/Μετοχές"),
      },
      {
        accessorKey: "nominalPrice",
        header: t("Ονομαστική Αξία"),
      },
      {
        accessorKey: "actions",
        header: t("Ενέργειες"),
        enableColumnFilter: false,
        enableColumnActions: false,
        enableSorting: false,
        Cell: ({ row }) => (
          <TableActionsForStocks
            updateStock={updateStock}
            stockTypes={stockTypes?.data}
            companyId={companyId}
            appendStock={appendStock}
            row={row.original}
            index={row.index}
          />
        ),
      },
    ],
    [appendStock, companyId, stockTypes, t, updateStock],
  );

  const table = useCustomMaterialTable({
    columns: columns,
    data: stocks ?? [],
    localization: getTableLang(),
    rowCount: stocks?.length ?? 0,
    state: {
      isLoading: isFetching || isFetchingStockTypes,
    },
    muiTableBodyRowProps: ({ row }) => ({
      sx: {
        "& td:not(:last-child)": {
          textDecoration: row.original.toBeDeleted ? "line-through" : "none",
          opacity: row.original.toBeDeleted ? 0.5 : 1,
        },
      },
    }),
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
          startIcon={<AddIcon />}
          color={"primary"}
          variant={"contained"}
          onClick={() => setOpenAddModal(true)}
        >
          {t("Εισαγωγή Μετοχής")}
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
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          gap: "1rem",
          width: "100%",
        }}
      >
        <TextFieldElement
          name={"totalAmount"}
          label={t("Τρέχον Κεφάλαιο")}
          fullWidth={true}
          required={true}
        />
        <CurrencyAutocomplete isRequired={true} />
      </Box>
      <MaterialReactTable table={table} />
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          gap: "1rem",
          width: "100%",
        }}
      >
        <TextFieldElement
          name={"changeReason"}
          label={t("Αιτία Αλλαγής")}
          fullWidth={true}
          required={true}
          multiline={true}
          rows={5}
        />
      </Box>
      <EditAndAddStockModal
        appendStock={appendStock}
        companyId={companyId}
        updateStock={updateStock}
        stockTypes={stockTypes?.data}
        mode={"add"}
        open={openAddModal}
        setOpen={setOpenAddModal}
      />
    </Box>
  );
};
