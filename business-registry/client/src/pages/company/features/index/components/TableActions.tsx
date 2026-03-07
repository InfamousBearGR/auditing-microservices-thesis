import {IconButton, Tooltip} from "@mui/material";
import SearchIcon from "@mui/icons-material/Search";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import {DeleteModal} from "src/shared/components/DeleteModal";
import {useNavigate} from "@tanstack/react-router";
import {useState} from "react";
import {CompanyResponseDto} from "src/pages/company/types";
import {MRT_Row} from "material-react-table";
import {UseMutationResult} from "@tanstack/react-query";
import {AxiosResponse} from "axios";

type TableActionsProps = {
  row: MRT_Row<CompanyResponseDto>;
  table: string;
  useMutation: UseMutationResult<
    AxiosResponse,
    Error,
    { id: number; changeReason: string }
  >;
  editTitle: string;
  viewTitle: string;
  deleteTitle: string;
  deleteDescription: string;
};

export const TableActions = (props: TableActionsProps) => {
  const {
    row,
    table,
    useMutation,
    editTitle,
    viewTitle,
    deleteTitle,
    deleteDescription,
  } = props;
  const [openDeleteModal, setOpenDeleteModal] = useState<boolean>(false);
  const { mutate, isPending } = useMutation;
  const navigate = useNavigate();
  return (
    <>
      <Tooltip title={editTitle}>
        <IconButton
          color={"primary"}
          onClick={() =>
            navigate({
              to: `/${table}/view/$id`,
              params: { id: String(row.original.id) },
            })
          }
        >
          <SearchIcon />
        </IconButton>
      </Tooltip>
      <Tooltip title={viewTitle}>
        <IconButton
          color={"warning"}
          onClick={() =>
            navigate({
              to: `/${table}/edit/$id`,
              params: { id: String(row.original.id) },
            })
          }
        >
          <EditIcon />
        </IconButton>
      </Tooltip>
      <Tooltip title={deleteTitle}>
        <IconButton color={"error"} onClick={() => setOpenDeleteModal(true)}>
          <DeleteIcon />
        </IconButton>
      </Tooltip>
      <DeleteModal
        id={row.original.id}
        open={openDeleteModal}
        setOpen={setOpenDeleteModal}
        title={deleteTitle}
        description={`${deleteDescription}: ${row.original.name}?`}
        onConfirm={mutate}
        isPending={isPending}
      />
    </>
  );
};
