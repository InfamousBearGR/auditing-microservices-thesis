import { z } from "zod";
import { TFunction } from "i18next";

const validatePercentage = (value: string): boolean => {
  let normalized = value.trim();
  if (normalized.endsWith("%")) {
    normalized = normalized.slice(0, -1).trim();
  }
  try {
    let percentage: number;
    if (normalized.includes("/")) {
      const parts = normalized.split("/");
      if (parts.length !== 2) return false;
      const numerator = parts[0].trim();
      const denominator = parts[1].trim();
      if (
        !/^\d+(\.\d+)?$/.test(numerator) ||
        !/^\d+(\.\d+)?$/.test(denominator)
      )
        return false;
      const num = parseFloat(numerator);
      const den = parseFloat(denominator);
      if (den === 0) return false;
      percentage = num / den;
    } else {
      if (!/^\d+(\.\d+)?$/.test(normalized)) return false;
      percentage = parseFloat(normalized);
    }
    return !isNaN(percentage) && percentage >= 0 && percentage <= 100;
  } catch {
    return false;
  }
};

export const getMemberValidationSchema = (
  t: TFunction<"translation", undefined>,
) =>
  z
    .object({
      active: z.boolean({
        error: t("Το πεδίο Ενεργός είναι υποχρεωτικό"),
      }),
      dateFrom: z
        .date({ error: t("Το πεδίο Ημερομηνία Από είναι υποχρεωτικό") })
        .refine(
          (date) => date <= new Date(),
          t("Η Ημερομηνία Από δεν μπορεί να είναι μεταγενέστερη του σήμερα"),
        ),
      dateTo: z
        .date({ error: t("Το πεδίο Ημερομηνία Έως είναι υποχρεωτικό") })
        .refine(
          (date) => date >= new Date(new Date().setHours(0, 0, 0, 0)),
          t("Η Ημερομηνία Έως δεν μπορεί να είναι προγενέστερη του σήμερα"),
        ),
      percentageOfOwnership: z
        .string()
        .min(1, t("Το πεδίο Ποσοστό Ιδιοκτησίας είναι υποχρεωτικό"))
        .refine(
          validatePercentage,
          t("Το Ποσοστό Ιδιοκτησίας πρέπει να είναι ένας έγκυρος αριθμός"),
        ),
      memberRelationId: z
        .number({ error: t("Το πεδίο Ιδιότητα είναι υποχρεωτικό") })
        .min(1, t("Το πεδίο Ιδιότητα είναι υποχρεωτικό")),
      representedIndividual: z.boolean({
        error: t("Το πεδίο Εκπροσωπείται Μεμονωμένα είναι υποχρεωτικό"),
      }),
      representedTogether: z.boolean({
        error: t("Το πεδίο Εκπροσωπείται Από Κοινού είναι υποχρεωτικό"),
      }),
      changeReason: z
        .string()
        .min(1, t("Το πεδίο Αιτία Αλλαγής είναι υποχρεωτικό")),
      personId: z.number().nullable().optional(),
      legalEntityId: z.number().nullable().optional(),
      representativeOfMemberId: z.number().nullable().optional(),
    })
    .superRefine((data, ctx) => {
      // dateTo must not be before dateFrom
      if (data.dateFrom && data.dateTo && data.dateTo < data.dateFrom) {
        ctx.addIssue({
          code: "custom",
          message: t(
            "Η Ημερομηνία Έως δεν μπορεί να είναι προγενέστερη της Ημερομηνία Από",
          ),
          path: ["dateTo"],
        });
      }

      // Must be either person or legal entity, not both, not neither
      if (data.legalEntityId && data.personId) {
        ctx.addIssue({
          code: "custom",
          message: t(
            "Ο Εταίρος δεν μπορεί να είναι ταυτόχρονα Φυσικό και Νομικό Πρόσωπο",
          ),
          path: ["personId"],
        });
      } else if (!data.legalEntityId && !data.personId) {
        ctx.addIssue({
          code: "custom",
          message: t(
            "Ο Εταίρος πρέπει να είναι είτε Φυσικό είτε Νομικό Πρόσωπο",
          ),
          path: ["personId"],
        });
      }

      // representativeOfMemberId is required when legalEntityId is set
      if (
        data.legalEntityId &&
        (data.representativeOfMemberId == null ||
          data.representativeOfMemberId <= 0)
      ) {
        ctx.addIssue({
          code: "custom",
          message: t(
            "Το πεδίο Εκπρόσωπος είναι υποχρεωτικό όταν ο Εταίρος είναι Νομικό Πρόσωπο",
          ),
          path: ["representativeOfMemberId"],
        });
      }

      // At least one of representedIndividual or representedTogether must be true
      if (!data.representedIndividual && !data.representedTogether) {
        ctx.addIssue({
          code: "custom",
          message: t(
            "Τουλάχιστον ένα από τα πεδία Εκπροσωπείται Μεμονωμένα ή Εκπροσωπείται Από Κοινού πρέπει να είναι επιλεγμένο",
          ),
          path: ["representedIndividual"],
        });
      }

      if (data.representedIndividual && data.representedTogether) {
        ctx.addIssue({
          code: "custom",
          message: t(
            "Τα πεδία Εκπροσωπείται Μεμονωμένα και Εκπροσωπείται Από Κοινού δεν μπορούν να είναι επιλεγμένα ταυτόχρονα",
          ),
          path: ["representedIndividual"],
        });
      }
    });

export type MemberValidationSchema = z.input<
  ReturnType<typeof getMemberValidationSchema>
>;
