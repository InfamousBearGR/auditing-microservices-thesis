import {
  CompanyCapitalValidationSchema,
  CompanyStockValidationSchema,
} from "src/pages/companyCapital/features/shared/validation/validationSchema";
import { UseFieldArrayAppend, UseFieldArrayUpdate } from "react-hook-form";
import {
  Dispatch,
  SetStateAction,
  startTransition,
  useEffect,
  useState,
} from "react";
import { useFormContext, UseFormReturn } from "react-hook-form-mui";
import { enqueueSnackbar } from "notistack";
import { useTranslation } from "react-i18next";
import { ParametricDto } from "src/shared/types/types";
import {
  Autocomplete,
  Box,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  TextField,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";

type EditAndAddStockModalProps = {
  open: boolean;
  setOpen: Dispatch<SetStateAction<boolean>>;
  updateStock: UseFieldArrayUpdate<CompanyCapitalValidationSchema, "stocks">;
  appendStock: UseFieldArrayAppend<CompanyCapitalValidationSchema, "stocks">;
  index?: number;
  mode: "edit" | "add";
  stockTypes?: ParametricDto[];
  companyId: number;
};

export const EditAndAddStockModal = (props: EditAndAddStockModalProps) => {
  const {
    open,
    setOpen,
    updateStock,
    appendStock,
    index,
    mode,
    stockTypes,
    companyId,
  } = props;
  const { t } = useTranslation();

  const formContext: UseFormReturn<CompanyCapitalValidationSchema> =
    useFormContext();

  const getEditValues = () => {
    if (mode === "edit" && index !== undefined) {
      return {
        stockTypeId:
          (formContext.getValues(`stocks.${index}.stockTypeId`) as number) ??
          null,
        amount:
          (formContext.getValues(`stocks.${index}.amount`) as number) ?? null,
        nominalPrice:
          (formContext.getValues(`stocks.${index}.nominalPrice`) as string) ??
          null,
      };
    }
    return { stockTypeId: null, amount: null, nominalPrice: null };
  };

  const initial = getEditValues();
  const [stockTypeId, setStockTypeId] = useState<number | null>(
    initial.stockTypeId,
  );
  const [amount, setAmount] = useState<number | null>(initial.amount);
  const [nominalPrice, setNominalPrice] = useState<string | null>(
    initial.nominalPrice,
  );

  useEffect(() => {
    if (mode === "edit" && index !== undefined) {
      const values = {
        stockTypeId:
          (formContext.getValues(`stocks.${index}.stockTypeId`) as number) ??
          null,
        amount:
          (formContext.getValues(`stocks.${index}.amount`) as number) ?? null,
        nominalPrice:
          (formContext.getValues(`stocks.${index}.nominalPrice`) as string) ??
          null,
      };
      startTransition(() => {
        setStockTypeId(values.stockTypeId);
        setAmount(values.amount);
        setNominalPrice(values.nominalPrice);
      });
    } else if (mode === "add") {
      startTransition(() => {
        setStockTypeId(null);
        setAmount(null);
        setNominalPrice(null);
      });
    }
  }, [open, formContext, mode, index]);

  const handleSave = () => {
    if (stockTypeId === null || amount === null || nominalPrice === null) {
      return enqueueSnackbar(t("Παρακαλώ συμπληρώστε όλα τα πεδία."), {
        variant: "error",
      });
    }
    const stockData: CompanyStockValidationSchema = {
      id:
        mode === "edit" && index !== undefined
          ? ((formContext.getValues(
              `stocks.${index}.id` as `stocks.${number}.id`,
            ) as unknown as number) ?? undefined)
          : undefined,
      companyId: companyId,
      stockTypeId: stockTypeId,
      amount: amount,
      nominalPrice: nominalPrice,
      toBeDeleted: false,
    };
    const existingIndex: number | undefined = formContext
      .watch("stocks")
      ?.findIndex(
        (stock: CompanyStockValidationSchema) =>
          stock.stockTypeId === stockTypeId,
      );
    if (mode === "add" && existingIndex !== -1) {
      return enqueueSnackbar(t("Η μετοχή με αυτό το είδος υπάρχει ήδη."), {
        variant: "error",
      });
    } else if (mode === "edit" && existingIndex !== index) {
      return enqueueSnackbar(t("Η μετοχή με αυτό το είδος υπάρχει ήδη."), {
        variant: "error",
      });
    }
    if (mode === "edit" && index !== undefined) {
      updateStock(index, stockData);
    } else if (mode === "add") {
      appendStock(stockData);
    }
    setOpen(false);
  };

  return (
    <Dialog maxWidth="xl" fullWidth open={open} onClose={() => {}}>
      <DialogTitle>
        {t(
          `${mode === "edit" ? t("Επεξεργασία Μετοχής") : t("Εισαγωγή Μετοχής")} `,
        )}
      </DialogTitle>
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
          {stockTypes && (
            <Autocomplete
              value={stockTypeId}
              renderInput={(params) => (
                <TextField {...params} label={t("Είδος Μετοχής")} />
              )}
              sx={{ width: "100%" }}
              onChange={(_, value) => setStockTypeId(value ?? null)}
              options={stockTypes.map((stockType) => stockType.id)}
              isOptionEqualToValue={(option, value) => option === value}
              getOptionLabel={(e) =>
                stockTypes?.find((stockType) => stockType.id === e)
                  ?.description || ""
              }
            />
          )}
          <TextField
            label={t("Μερίδιο/Μετοχές")}
            fullWidth
            value={amount}
            onChange={(e) =>
              setAmount(e.target.value ? Number(e.target.value) : null)
            }
            type={"number"}
          />
          <TextField
            label={t("Ονομαστική Αξία")}
            fullWidth
            value={nominalPrice}
            onChange={(e) =>
              setNominalPrice(e.target.value ? e.target.value : null)
            }
            type={"number"}
          />
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
          <Button variant={"contained"} color={"primary"} onClick={handleSave}>
            {mode === "edit" ? t("Αποθήκευση") : t("Εισαγωγή")}
          </Button>
        </>
      </DialogActions>
    </Dialog>
  );
};
