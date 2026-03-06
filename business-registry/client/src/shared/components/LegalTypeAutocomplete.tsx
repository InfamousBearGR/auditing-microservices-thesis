import { useTranslation } from "react-i18next";
import { useGetLegalTypes } from "src/shared/data-access/useGetLegalTypes";
import { AutocompleteElement } from "react-hook-form-mui";
import { CustomAutocompleteProps } from "src/shared/types/types";

export const LegalTypeAutocomplete = (props: CustomAutocompleteProps) => {
  const { isRequired } = props;
  const { t } = useTranslation();
  const { data, isFetching } = useGetLegalTypes();

  return (
    <AutocompleteElement
      label={t("Νομική Μορφή")}
      required={isRequired}
      loading={isFetching}
      name={"legalTypeId"}
      options={data?.data?.map((legalType) => legalType.id) ?? []}
      autocompleteProps={{
        sx: { width: "100%" },
        isOptionEqualToValue: (option, value) => option === value,
        getOptionLabel: (option) =>
          data?.data?.find((legalType) => legalType.id === option)
            ?.description || "",
      }}
    />
  );
};
