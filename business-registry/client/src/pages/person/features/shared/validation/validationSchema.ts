import { z } from "zod";
import { TFunction } from "i18next";
import { validateAfm } from "src/shared/utils";

export const getPersonValidationSchema = (
  t: TFunction<"translation", undefined>,
) =>
  z.object({
    name: z.string().min(1, t("Το πεδίο Όνομα είναι υποχρεωτικό")),
    surname: z.string().min(1, t("Το πεδίο Επώνυμο είναι υποχρεωτικό")),
    afm: z
      .string()
      .min(1, t("Το πεδίο ΑΦΜ είναι υποχρεωτικό"))
      .refine(validateAfm, t("Το ΑΦΜ δεν είναι έγκυρο")),
    city: z.string().min(1, t("Το πεδίο Πόλη είναι υποχρεωτικό")),
    street: z.string().min(1, t("Το πεδίο Οδός είναι υποχρεωτικό")),
    streetNumber: z.string().min(1, t("Το πεδίο Αριθμός είναι υποχρεωτικό")),
    postalCode: z
      .string()
      .min(1, t("Το πεδίο Ταχυδρομικός Κώδικας είναι υποχρεωτικό")),
    birthDate: z.date({
      error: t("Το πεδίο Ημερομηνία Γέννησης είναι υποχρεωτικό"),
    }),
    birthPlace: z
      .string()
      .min(1, t("Το πεδίο Τόπος Γέννησης είναι υποχρεωτικό")),
    identityNumber: z
      .string()
      .min(1, t("Το πεδίο Αριθμός Ταυτότητας είναι υποχρεωτικό")),
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
    phoneNumber: z.string().min(1, t("Το πεδίο Τηλέφωνο είναι υποχρεωτικό")),
    changeReason: z
      .string()
      .min(1, t("Το πεδίο Αιτία Αλλαγής είναι υποχρεωτικό")),
  });

export type PersonValidationSchema = z.input<
  ReturnType<typeof getPersonValidationSchema>
>;
