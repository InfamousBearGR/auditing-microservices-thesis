import {Box} from "@mui/material";
import {TextFieldElement, useFormContext, UseFormReturn,} from "react-hook-form-mui";
import {useEffect, useRef} from "react";
import {CompanyStatusAutocomplete} from "src/shared/components/CompanyStatusAutocomplete";
import {LegalTypeAutocomplete} from "src/shared/components/LegalTypeAutocomplete";
import {CustomDatePicker} from "src/shared/components/CustomDatePicker";
import {CountryAutocomplete} from "src/shared/components/CountryAutocomplete";
import {PrefectureAutocomplete} from "src/shared/components/PrefectureAutocomplete";
import {RegionAutocomplete} from "src/shared/components/RegionAutocomplete";
import {MunicipalityAutocomplete} from "src/shared/components/MunicipalityAutocomplete";
import {useTranslation} from "react-i18next";
import {CompanyValidationSchema} from "src/pages/company/features/shared/validation/validationSchema";

export const CompanyForm = () => {
  const { t } = useTranslation();
  const formContext: UseFormReturn<CompanyValidationSchema> = useFormContext();
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
          name={"registryNumber"}
          label={t("Αριθμός Μητρώου")}
          fullWidth={true}
          required={true}
        />
        <TextFieldElement
          name={"name"}
          label={t("Επωνυμία Επιχείρησης")}
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
        <CompanyStatusAutocomplete isRequired={true} />
        <LegalTypeAutocomplete isRequired={true} />
        <CustomDatePicker
          name={"dateIncorporated"}
          label={t("Ημερομηνία Ίδρυσης")}
          maxDate={new Date()}
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
