import { z } from "zod";
import { TFunction } from "i18next";
import { validateAfm } from "src/shared/utils";

export const getLegalEntityValidationSchema = (
  t: TFunction<"translation", undefined>,
) =>
  z.object({
    registryNumber: z
      .string()
      .min(1, t("Το πεδίο Αριθμός Μητρώου είναι υποχρεωτικό")),
    businessName: z
      .string()
      .min(1, t("Το πεδίο Επωνυμία Νομικού Προσώπου είναι υποχρεωτικό")),
    afm: z
      .string()
      .min(1, t("Το πεδίο ΑΦΜ είναι υποχρεωτικό"))
      .refine(validateAfm, t("Το ΑΦΜ δεν είναι έγκυρο")),
    phoneNumber: z.string().min(1, t("Το πεδίο Τηλέφωνο είναι υποχρεωτικό")),
    city: z.string().min(1, t("Το πεδίο Πόλη είναι υποχρεωτικό")),
    street: z.string().min(1, t("Το πεδίο Οδός είναι υποχρεωτικό")),
    streetNumber: z.string().min(1, t("Το πεδίο Αριθμός είναι υποχρεωτικό")),
    postalCode: z
      .string()
      .min(1, t("Το πεδίο Ταχυδρομικός Κώδικας είναι υποχρεωτικό")),
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
    changeReason: z
      .string()
      .min(1, t("Το πεδίο Αιτία Αλλαγής είναι υποχρεωτικό")),
  });

export type LegalEntityValidationSchema = z.input<
  ReturnType<typeof getLegalEntityValidationSchema>
>;
