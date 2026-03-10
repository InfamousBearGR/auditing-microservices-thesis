import { z } from "zod";
import { TFunction } from "i18next";
import { validateAfm } from "src/shared/utils";

export const getCompanyValidationSchema = (
  t: TFunction<"translation", undefined>,
) =>
  z.object({
    name: z
      .string()
      .min(1, t("Το πεδίο Επωνυμία Επιχείρησης είναι υποχρεωτικό")),
    city: z.string().min(1, t("Το πεδίο Πόλη είναι υποχρεωτικό")),
    street: z.string().min(1, t("Το πεδίο Οδός είναι υποχρεωτικό")),
    streetNumber: z.string().min(1, t("Το πεδίο Αριθμός είναι υποχρεωτικό")),
    postalCode: z
      .string()
      .min(1, t("Το πεδίο Ταχυδρομικός Κώδικας είναι υποχρεωτικό")),
    afm: z
      .string()
      .min(1, t("Το πεδίο ΑΦΜ είναι υποχρεωτικό"))
      .refine(validateAfm, t("Το ΑΦΜ δεν είναι έγκυρο")),
    dateIncorporated: z.date({
      error: t("Το πεδίο Ημερομηνία Ίδρυσης είναι υποχρεωτικό"),
    }),
    registryNumber: z
      .string()
      .min(1, t("Το πεδίο Αριθμός Μητρώου είναι υποχρεωτικό"))
      .length(12, t("Ο Αριθμός Μητρώου πρέπει να έχει 12 ψηφία")),
    countryId: z
      .number({ error: t("Το πεδίο Χώρα είναι υποχρεωτικό") })
      .min(1, t("Το πεδίο Χώρα είναι υποχρεωτικό")),
    prefectureId: z
      .number({ error: t("Το πεδίο Νομός είναι υποχρεωτικό") })
      .min(1, t("Το πεδίο Νομός είναι υποχρεωτικό")),
    municipalityId: z
      .number({ error: t("Το πεδίο Δήμος είναι υποχρεωτικό") })
      .min(1, t("Το πεδίο Δήμος είναι υποχρεωτικό")),
    regionId: z
      .number({ error: t("Το πεδίο Περιφέρεια είναι υποχρεωτικό") })
      .min(1, t("Το πεδίο Περιφέρεια είναι υποχρεωτικό")),
    legalTypeId: z
      .number({ error: t("Το πεδίο Νομική Μορφή είναι υποχρεωτικό") })
      .min(1, t("Το πεδίο Νομική Μορφή είναι υποχρεωτικό")),
    companyStatusId: z
      .number({ error: t("Το πεδίο Κατάσταση Επιχείρησης είναι υποχρεωτικό") })
      .min(1, t("Το πεδίο Κατάσταση Επιχείρησης είναι υποχρεωτικό")),
    changeReason: z
      .string()
      .min(1, t("Το πεδίο Αιτία Αλλαγής είναι υποχρεωτικό")),
  });

export type CompanyValidationSchema = z.input<
  ReturnType<typeof getCompanyValidationSchema>
>;
