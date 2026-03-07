import {useTranslation} from "react-i18next";
import {Box, Button, Typography} from "@mui/material";
import {useIndexCompany} from "src/pages/company/data-access/useIndexCompany";
import {enqueueSnackbar} from "notistack";
import {useMemo} from "react";
import {MaterialReactTable, MRT_ColumnDef} from "material-react-table";
import {CompanyResponseDto} from "src/pages/company/types";
import {useCustomMaterialTable} from "src/shared/hooks/useCustomMaterialTable";
import {getTableLang} from "src/shared/services/languages/MaterialReactTable/getTableLang";
import {TableActions} from "src/pages/company/features/index/components/TableActions";
import {useQueryClient} from "@tanstack/react-query";
import ReplayIcon from "@mui/icons-material/Replay";
import {FormContainer, useForm} from "react-hook-form-mui";
import {CompanyStatusAutocomplete} from "src/shared/components/CompanyStatusAutocomplete";
import {LegalTypeAutocomplete} from "src/shared/components/LegalTypeAutocomplete";
import {useDeleteCompany} from "src/pages/company/data-access/useDeleteCompany";
import AddBusinessIcon from "@mui/icons-material/AddBusiness";
import {useNavigate} from "@tanstack/react-router";
import SearchIcon from "@mui/icons-material/Search";

export const Index = () => {
  const formContext = useForm();
  const { t, i18n } = useTranslation();
  const { data, isError, isFetching } = useIndexCompany(
    formContext.watch("companyStatusId"),
    formContext.watch("legalTypeId"),
  );
  const queryClient = useQueryClient();

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση των επιχειρήσεων"), {
      variant: "error",
    });
  }

  const navigate = useNavigate();

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
        header: t("Κατάσταση Επιχείρησης"),
        accessorKey: "companyStatus.description",
      },
      {
        accessorKey: "actions",
        header: t("Ενέργειες"),
        Cell: ({ row }) => (
          <TableActions
            row={row}
            table={"company"}
            useMutation={useDeleteCompany()}
            editTitle={t("Επεξεργασία Επιχείρησης")}
            viewTitle={t("Προβολή Επιχείρησης")}
            deleteTitle={t("Διαγραφή Επιχείρησης")}
            deleteDescription={t(
              "Είστε σίγουροι ότι θέλετε να διαγράψετε αυτή την επιχείρηση;",
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
          startIcon={<AddBusinessIcon />}
          color={"primary"}
          variant={"contained"}
          onClick={() =>
            navigate({
              to: `/company/add`,
            })
          }
        >
          {t("Εισαγωγή Επιχείρησης")}
        </Button>
        <Button
          color={"info"}
          onClick={() =>
            queryClient.invalidateQueries({ queryKey: ["indexCompany"] })
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
      <Typography variant={"h5"}>{t("Ευρετήριο Επιχειρήσεων")}</Typography>

      <FormContainer
        formContext={formContext}
        onSuccess={async () => {
          await queryClient.invalidateQueries({ queryKey: ["indexCompany"] });
        }}
      >
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
            <CompanyStatusAutocomplete />
            <LegalTypeAutocomplete />
          </Box>
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
              variant={"contained"}
              startIcon={<SearchIcon />}
              type={"submit"}
              loading={isFetching}
            >
              {t("Αναζήτηση")}
            </Button>
          </Box>
        </Box>
      </FormContainer>

      <MaterialReactTable table={table} />
    </Box>
  );
};
