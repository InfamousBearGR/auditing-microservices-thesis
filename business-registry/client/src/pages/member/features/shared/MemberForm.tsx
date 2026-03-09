import { Box } from "@mui/material";
import {
  AutocompleteElement,
  CheckboxElement,
  TextFieldElement,
  useFormContext,
  UseFormReturn,
} from "react-hook-form-mui";
import { useEffect, useRef } from "react";
import { CustomDatePicker } from "src/shared/components/CustomDatePicker";
import { MemberRelationAutocomplete } from "src/shared/components/MemberRelationAutocomplete";
import { useTranslation } from "react-i18next";
import { MemberValidationSchema } from "src/pages/member/features/shared/validation/validationSchema";
import { useSearchPersons } from "src/pages/member/data-access/useSearchPersons";
import { useSearchLegalEntities } from "src/pages/member/data-access/useSearchLegalEntities";

export const MemberForm = () => {
  const { t } = useTranslation();
  const formContext: UseFormReturn<MemberValidationSchema> = useFormContext();
  const personId = formContext.watch("personId");
  const legalEntityId = formContext.watch("legalEntityId");
  const prevPersonId = useRef<unknown>(undefined);
  const prevLegalEntityId = useRef<unknown>(undefined);

  const { data: personsData, isFetching: isPersonsFetching } =
    useSearchPersons();
  const { data: legalEntitiesData, isFetching: isLegalEntitiesFetching } =
    useSearchLegalEntities();

  useEffect(() => {
    if (prevPersonId.current === undefined) {
      prevPersonId.current = personId;
      return;
    }
    if (prevPersonId.current !== personId && personId) {
      formContext.setValue("legalEntityId", null);
      formContext.setValue("representativeOfMemberId", null);
    }
    prevPersonId.current = personId;
  }, [personId, formContext]);

  useEffect(() => {
    if (prevLegalEntityId.current === undefined) {
      prevLegalEntityId.current = legalEntityId;
      return;
    }
    if (prevLegalEntityId.current !== legalEntityId && legalEntityId) {
      formContext.setValue("personId", null);
    }
    prevLegalEntityId.current = legalEntityId;
  }, [legalEntityId, formContext]);

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
        <AutocompleteElement
          label={t("Φυσικό Πρόσωπο")}
          name={"personId"}
          loading={isPersonsFetching}
          options={personsData?.data?.map((p) => p.id) ?? []}
          autocompleteProps={{
            disabled: !!legalEntityId,
            sx: { width: "100%" },
            isOptionEqualToValue: (option, value) => option === value,
            getOptionLabel: (option) =>
              personsData?.data?.find((p) => p.id === option)?.description ||
              "",
          }}
        />
        <AutocompleteElement
          label={t("Νομικό Πρόσωπο")}
          name={"legalEntityId"}
          loading={isLegalEntitiesFetching}
          options={legalEntitiesData?.data?.map((le) => le.id) ?? []}
          autocompleteProps={{
            disabled: !!personId,
            sx: { width: "100%" },
            isOptionEqualToValue: (option, value) => option === value,
            getOptionLabel: (option) =>
              legalEntitiesData?.data?.find((le) => le.id === option)
                ?.description || "",
          }}
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
        {!!legalEntityId && (
          <AutocompleteElement
            label={t("Εκπρόσωπος")}
            name={"representativeOfMemberId"}
            loading={isPersonsFetching}
            options={personsData?.data?.map((p) => p.id) ?? []}
            required={true}
            autocompleteProps={{
              sx: { width: "100%" },
              isOptionEqualToValue: (option, value) => option === value,
              getOptionLabel: (option) =>
                personsData?.data?.find((p) => p.id === option)?.description ||
                "",
            }}
          />
        )}
        <MemberRelationAutocomplete isRequired={true} />
      </Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: "row",
          gap: "1rem",
          width: "100%",
        }}
      >
        <CustomDatePicker
          name={"dateFrom"}
          label={t("Ημερομηνία Από")}
          maxDate={new Date()}
          required={true}
        />
        <CustomDatePicker
          name={"dateTo"}
          label={t("Ημερομηνία Έως")}
          minDate={formContext.watch("dateFrom")}
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
          name={"percentageOfOwnership"}
          label={t("Ποσοστό Ιδιοκτησίας")}
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
          alignItems: "center",
        }}
      >
        <CheckboxElement name={"active"} label={t("Ενεργός")} />
        <CheckboxElement
          name={"representedIndividual"}
          label={t("Εκπροσωπείται Μεμονωμένα")}
        />
        <CheckboxElement
          name={"representedTogether"}
          label={t("Εκπροσωπείται Από Κοινού")}
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
