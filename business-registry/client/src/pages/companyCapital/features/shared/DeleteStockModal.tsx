import {
  Box,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  Typography,
} from "@mui/material";
import { Dispatch, SetStateAction } from "react";
import { UseFieldArrayUpdate } from "react-hook-form";
import { CompanyCapitalValidationSchema } from "src/pages/companyCapital/features/shared/validation/validationSchema";
import { Details } from "src/shared/components/Details/Details";
import CloseIcon from "@mui/icons-material/Close";
import { useFormContext, UseFormReturn } from "react-hook-form-mui";
import { useTranslation } from "react-i18next";
import { ParametricDto } from "src/shared/types/types";

type DeleteStockModalProps = {
  open: boolean;
  setOpen: Dispatch<SetStateAction<boolean>>;
  index: number;
  updateStock: UseFieldArrayUpdate<CompanyCapitalValidationSchema, "stocks">;
  companyId: number;
  stockTypes?: ParametricDto[];
};

export const DeleteStockModal = (props: DeleteStockModalProps) => {
  const { t } = useTranslation();
  const { open, setOpen, index, updateStock, companyId, stockTypes } = props;
  const formContext: UseFormReturn<CompanyCapitalValidationSchema> =
    useFormContext();
  const removeStockModal = () => {
    const currentStock = formContext.getValues(`stocks.${index}`);
    if (!currentStock) return;
    const stockData = {
      ...currentStock,
      stockTypeId: currentStock.stockTypeId ?? 0,
      amount: currentStock.amount ?? 0,
      nominalPrice: currentStock.nominalPrice ?? "",
      toBeDeleted: true,
      companyId: companyId,
    };
    updateStock(index, stockData);
    setOpen(false);
  };
  const rows: { name: string; value: string }[] = [
    {
      name: t("Είδος Μετοχής"),
      value: (() => {
        const stockTypeId = formContext.getValues(
          `stocks.${index}.stockTypeId`,
        ) as number;
        const stockType = stockTypes?.find((type) => type.id === stockTypeId);
        return stockType ? stockType.description : "";
      })(),
    },
    {
      name: t("Μερίδιο/Μετοχές"),
      value: formContext.getValues(`stocks.${index}.amount`)?.toString() ?? "",
    },
    {
      name: t("Ονομαστική Αξία"),
      value:
        formContext.getValues(`stocks.${index}.nominalPrice`)?.toString() ?? "",
    },
  ];
  return (
    <Dialog maxWidth="md" fullWidth open={open} onClose={() => {}}>
      <DialogTitle>
        {t(`Διαγραφή Μετοχής`)}
        <IconButton
          aria-label="close"
          onClick={() => setOpen(false)}
          sx={(theme) => ({
            position: "absolute",
            right: 8,
            top: 8,
            color: theme.palette.grey[500],
          })}
        >
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent>
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: "1rem",
            mx: "auto",
            mb: "2rem",
          }}
        >
          <Typography variant={"body1"}>
            {t(`Είστε σίγουρος/η για την διαγραφή της Μετοχής;`)}
          </Typography>
          <Details rows={rows} />
        </Box>
      </DialogContent>
      <DialogActions>
        <>
          <Button
            variant={"contained"}
            color={"error"}
            onClick={() => setOpen(false)}
          >
            {t("Ακύρωση")}
          </Button>
          <Button
            variant={"contained"}
            color={"primary"}
            onClick={removeStockModal}
          >
            {t("Επιβεβαίωση")}
          </Button>
        </>
      </DialogActions>
    </Dialog>
  );
};
