import { z } from "zod";
import { TFunction } from "i18next";

const DECIMAL_REGEX = /^-?\d+(\.\d{1,2})?$/;

const validateBigDecimal = (value: string): boolean => {
  if (!value || value.trim() === "") return false;
  return DECIMAL_REGEX.test(value.trim());
};

export const getCompanyStockValidationSchema = (
  t: TFunction<"translation", undefined>,
) => {
  return z.object({
    id: z.number().optional(),
    companyId: z.number(),
    stockTypeId: z
      .number({ error: t("Μη έγκυρος τύπος μετοχής") })
      .min(1, t("Μη έγκυρος τύπος μετοχής")),
    amount: z
      .number({ error: t("Μη έγκυρος αριθμός μετοχών") })
      .min(0, t("Μη έγκυρος αριθμός μετοχών")),
    nominalPrice: z
      .string()
      .min(1, t("Μη έγκυρη τιμή μετοχής"))
      .refine(
        (v) => validateBigDecimal(v),
        t(
          "Μη έγκυρη τιμή μετοχής. Η ονομαστική αξία μπορεί να έχει μέχρι δύο δεκαδικά ψηφία",
        ),
      )
      .refine(
        (v) => parseFloat(v.trim()) >= 0,
        t("Η ονομαστική αξία δεν μπορεί να είναι αρνητικός αριθμός"),
      ),
    toBeDeleted: z.boolean(),
  });
};

export const getCompanyCapitalValidationSchema = (
  t: TFunction<"translation", undefined>,
) => {
  return z
    .object({
      companyId: z
        .number({ error: t("Μη έγκυρο id επιχείρησης") })
        .min(1, t("Μη έγκυρο id επιχείρησης")),
      totalAmount: z
        .string()
        .min(1, t("Μη έγκυρο ποσό"))
        .refine(
          (v) => validateBigDecimal(v),
          t(
            "Μη έγκυρο ποσό. Το τρέχον κεφάλαιο μπορεί να έχει μέχρι δύο δεκαδικά ψηφία",
          ),
        )
        .refine(
          (v) => parseFloat(v.trim()) >= 0,
          t(
            "Μη έγκυρο ποσό. Το τρέχον κεφάλαιο δεν μπορεί να είναι αρνητικός αριθμός",
          ),
        ),
      currencyId: z
        .number({ error: t("Μη έγκυρο id νομίσματος") })
        .min(1, t("Μη έγκυρο id νομίσματος")),
      changeReason: z
        .string()
        .min(1, t("Το πεδίο Αιτία Αλλαγής είναι υποχρεωτικό")),
      stocks: z.array(getCompanyStockValidationSchema(t)).default([]),
    })
    .superRefine((data, ctx) => {
      const activeStocks = (data.stocks ?? []).filter((s) => !s.toBeDeleted);
      const stocksTotal = activeStocks.reduce((acc, s) => {
        if (!validateBigDecimal(s.nominalPrice)) return acc;
        return acc + parseFloat(s.nominalPrice.trim()) * Number(s.amount);
      }, 0);
      const totalAmount = parseFloat(data.totalAmount.trim());
      if (Math.abs(stocksTotal - totalAmount) > 1e-9) {
        ctx.addIssue({
          code: "custom",
          message: t("Το σύνολο μετοχών δεν ισούται με το κεφάλαιο"),
          path: ["stocks"],
        });
      }
    });
};

export type CompanyCapitalValidationSchema = z.input<
  ReturnType<typeof getCompanyCapitalValidationSchema>
>;

export type CompanyStockValidationSchema = z.input<
  ReturnType<typeof getCompanyStockValidationSchema>
>;
