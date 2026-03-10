import { IconButton, Tooltip } from "@mui/material";
import SearchIcon from "@mui/icons-material/Search";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import { DeleteModal } from "src/shared/components/DeleteModal";
import { useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import { UseMutationResult } from "@tanstack/react-query";
import { AxiosResponse } from "axios";

type TableActionsProps = {
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
  id: number;
  name: string;
  viewPath?: string;
};

export const TableActions = (props: TableActionsProps) => {
  const {
    id,
    name,
    table,
    useMutation,
    editTitle,
    viewTitle,
    deleteTitle,
    deleteDescription,
    viewPath,
  } = props;
  const [openDeleteModal, setOpenDeleteModal] = useState<boolean>(false);
  const { mutate, isPending } = useMutation;
  const navigate = useNavigate();
  return (
    <>
      <Tooltip title={viewTitle}>
        <IconButton
          color={"primary"}
          onClick={() =>
            navigate({
              to: viewPath ?? `/${table}/view/$id`,
              params: { id: String(id) },
            })
          }
        >
          <SearchIcon />
        </IconButton>
      </Tooltip>
      <Tooltip title={editTitle}>
        <IconButton
          color={"warning"}
          onClick={() =>
            navigate({
              to: `/${table}/edit/$id`,
              params: { id: String(id) },
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
        id={id}
        open={openDeleteModal}
        setOpen={setOpenDeleteModal}
        title={deleteTitle}
        description={`${deleteDescription}: ${name}?`}
        onConfirm={mutate}
        isPending={isPending}
      />
    </>
  );
};
