import { IconButton, Tooltip } from "@mui/material";
import { useTranslation } from "react-i18next";
import SearchIcon from "@mui/icons-material/Search";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import { DeleteModal } from "src/shared/components/DeleteModal";
import { useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { useDeleteCompany } from "src/pages/company/data-access/useDeleteCompany";
import { CompanyResponseDto } from "src/pages/company/types";
import { MRT_Row } from "material-react-table";

type TableActionsProps = {
  row: MRT_Row<CompanyResponseDto>;
};

export const TableActions = (props: TableActionsProps) => {
  const { row } = props;
  const { t } = useTranslation();
  const [openDeleteModal, setOpenDeleteModal] = useState<boolean>(false);
  const { mutate, isPending } = useDeleteCompany();
  const navigate = useNavigate();
  return (
    <>
      <Tooltip title={t("Προβολή Επιχείρησης")}>
        <IconButton
          color={"primary"}
          onClick={() =>
            navigate({
              to: "/company/view/$id",
              params: { id: String(row.original.id) },
            })
          }
        >
          <SearchIcon />
        </IconButton>
      </Tooltip>
      <Tooltip title={t("Επεξεργασία Επιχείρησης")}>
        <IconButton
          color={"warning"}
          onClick={() => navigate({ to: `/company/edit/${row.original.id}` })}
        >
          <EditIcon />
        </IconButton>
      </Tooltip>
      <Tooltip title={t("Διαγραφή Επιχείρησης")}>
        <IconButton color={"error"} onClick={() => setOpenDeleteModal(true)}>
          <DeleteIcon />
        </IconButton>
      </Tooltip>
      <DeleteModal
        id={row.original.id}
        open={openDeleteModal}
        setOpen={setOpenDeleteModal}
        title={t("Διαγραφή Επιχείρησης")}
        description={`${t(
          "Είστε σίγουροι ότι θέλετε να διαγράψετε αυτή την επιχείρηση",
        )}: ${row.original.name}?`}
        onConfirm={mutate}
        isPending={isPending}
      />
    </>
  );
};
