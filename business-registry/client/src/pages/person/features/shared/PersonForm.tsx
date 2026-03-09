import { Box } from "@mui/material";
import {
  TextFieldElement,
  useFormContext,
  UseFormReturn,
} from "react-hook-form-mui";
import { useEffect, useRef } from "react";
import { CountryAutocomplete } from "src/shared/components/CountryAutocomplete";
import { PrefectureAutocomplete } from "src/shared/components/PrefectureAutocomplete";
import { RegionAutocomplete } from "src/shared/components/RegionAutocomplete";
import { MunicipalityAutocomplete } from "src/shared/components/MunicipalityAutocomplete";
import { CustomDatePicker } from "src/shared/components/CustomDatePicker";
import { useTranslation } from "react-i18next";
import { PersonValidationSchema } from "src/pages/person/features/shared/validation/validationSchema";

export const PersonForm = () => {
  const { t } = useTranslation();
  const formContext: UseFormReturn<PersonValidationSchema> = useFormContext();
  const prefectureId = formContext.watch("prefectureId");
  const regionId = formContext.watch("regionId");
  const prevPrefectureId = useRef<unknown>(undefined);
  const prevRegionId = useRef<unknown>(undefined);

  useEffect(() => {
    if (prevRegionId.current === undefined) {
      prevRegionId.current = regionId;
      return;
    }
    if (prevRegionId.current !== regionId) {
      prevRegionId.current = regionId;
      formContext.setValue("prefectureId", null as unknown as number);
      formContext.setValue("municipalityId", null as unknown as number);
    }
  }, [regionId, formContext]);

  useEffect(() => {
    if (prevPrefectureId.current === undefined) {
      prevPrefectureId.current = prefectureId;
      return;
    }
    if (prevPrefectureId.current !== prefectureId) {
      prevPrefectureId.current = prefectureId;
      formContext.setValue("municipalityId", null as unknown as number);
    }
  }, [prefectureId, formContext]);

  return (
    <>
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          gap: "1rem",
          width: "100%",
        }}
      >
        <TextFieldElement
          name={"name"}
          label={t("Όνομα")}
          fullWidth={true}
          required={true}
        />
        <TextFieldElement
          name={"surname"}
          label={t("Επώνυμο")}
          fullWidth={true}
          required={true}
        />
        <TextFieldElement
          name={"afm"}
          label={t("ΑΦΜ")}
          fullWidth={true}
          required={true}
        />
      </Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          gap: "1rem",
          width: "100%",
        }}
      >
        <TextFieldElement
          name={"identityNumber"}
          label={t("Αριθμός Ταυτότητας")}
          fullWidth={true}
          required={true}
        />
        <CustomDatePicker
          name={"birthDate"}
          label={t("Ημερομηνία Γέννησης")}
          maxDate={new Date()}
          required={true}
        />
        <TextFieldElement
          name={"birthPlace"}
          label={t("Τόπος Γέννησης")}
          fullWidth={true}
          required={true}
        />
      </Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          gap: "1rem",
          width: "100%",
        }}
      >
        <CountryAutocomplete isRequired={true} />
        <RegionAutocomplete isRequired={true} />
        <PrefectureAutocomplete isRequired={true} idForSearch={regionId} />
      </Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          gap: "1rem",
          width: "100%",
        }}
      >
        <MunicipalityAutocomplete
          isRequired={true}
          idForSearch={prefectureId}
        />
        <TextFieldElement
          name={"city"}
          label={t("Πόλη")}
          fullWidth={true}
          required={true}
        />
        <TextFieldElement
          name={"street"}
          label={t("Οδός")}
          fullWidth={true}
          required={true}
        />
      </Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          gap: "1rem",
          width: "100%",
        }}
      >
        <TextFieldElement
          name={"streetNumber"}
          label={t("Αριθμός")}
          fullWidth={true}
          required={true}
        />
        <TextFieldElement
          name={"postalCode"}
          label={t("Ταχυδρομικός Κώδικας")}
          fullWidth={true}
          required={true}
        />
        <TextFieldElement
          name={"phoneNumber"}
          label={t("Τηλέφωνο")}
          fullWidth={true}
          required={true}
        />
      </Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          gap: "1rem",
          width: "100%",
        }}
      >
        <TextFieldElement
          name={"changeReason"}
          label={t("Αιτία Αλλαγής")}
          fullWidth={true}
          required={true}
          multiline={true}
          rows={5}
        />
      </Box>
    </>
  );
};
