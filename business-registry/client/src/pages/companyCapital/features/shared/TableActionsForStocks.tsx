import {
  CompanyCapitalValidationSchema,
  CompanyStockValidationSchema,
} from "src/pages/companyCapital/features/shared/validation/validationSchema";
import { UseFieldArrayAppend, UseFieldArrayUpdate } from "react-hook-form";
import { DeleteStockModal } from "src/pages/companyCapital/features/shared/DeleteStockModal";
import { IconButton, Tooltip } from "@mui/material";
import DeleteIcon from "@mui/icons-material/Delete";
import EditIcon from "@mui/icons-material/Edit";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { EditAndAddStockModal } from "src/pages/companyCapital/features/shared/EditAndAddStockModal";
import { ParametricDto } from "src/shared/types/types";
import UndoIcon from "@mui/icons-material/Undo";

type TableActionsForStocksProps = {
  row: CompanyStockValidationSchema;
  updateStock: UseFieldArrayUpdate<CompanyCapitalValidationSchema, "stocks">;
  appendStock: UseFieldArrayAppend<CompanyCapitalValidationSchema, "stocks">;
  index: number;
  companyId: number;
  stockTypes?: ParametricDto[];
};

export const TableActionsForStocks = (props: TableActionsForStocksProps) => {
  const { t } = useTranslation();
  const { row, updateStock, appendStock, index, companyId, stockTypes } = props;
  const [openRemoveModal, setOpenRemoveModal] = useState<boolean>(false);
  const [openEditAndAddModal, setOpenEditAndAddModal] =
    useState<boolean>(false);
  return (
    <>
      {row.toBeDeleted ? (
        <>
          <Tooltip title={t(`Αναίρεση Διαγραφής Μετοχής`)}>
            <IconButton
              color={"info"}
              sx={{ opacity: 1 }}
              onClick={() => updateStock(index, { ...row, toBeDeleted: false })}
            >
              <UndoIcon />
            </IconButton>
          </Tooltip>
        </>
      ) : (
        <>
          <Tooltip title={t(`Επεξεργασία Μετοχής`)}>
            <IconButton
              color={"primary"}
              onClick={() => setOpenEditAndAddModal(true)}
            >
              <EditIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title={t(`Διαγραφή Μετοχής`)}>
            <IconButton
              color={"error"}
              onClick={() => setOpenRemoveModal(true)}
            >
              <DeleteIcon />
            </IconButton>
          </Tooltip>
          <DeleteStockModal
            open={openRemoveModal}
            setOpen={setOpenRemoveModal}
            index={index}
            updateStock={updateStock}
            companyId={companyId}
            stockTypes={stockTypes}
          />
          <EditAndAddStockModal
            open={openEditAndAddModal}
            setOpen={setOpenEditAndAddModal}
            updateStock={updateStock}
            appendStock={appendStock}
            mode={"edit"}
            index={index}
            companyId={companyId}
            stockTypes={stockTypes}
          />
        </>
      )}
    </>
  );
};
