import { useTranslation } from "react-i18next";
import { useGetCountries } from "src/shared/data-access/useGetCountries";
import { AutocompleteElement } from "react-hook-form-mui";
import { CustomAutocompleteProps } from "src/shared/types/types";

export const CountryAutocomplete = (props: CustomAutocompleteProps) => {
  const { isRequired } = props;
  const { t } = useTranslation();
  const { data, isFetching } = useGetCountries();

  return (
    <AutocompleteElement
      label={t("Χώρα")}
      required={isRequired}
      name={"countryId"}
      loading={isFetching}
      options={data?.data?.map((country) => country.id) ?? []}
      autocompleteProps={{
        sx: { width: "100%" },
        isOptionEqualToValue: (option, value) => option === value,
        getOptionLabel: (option) =>
          data?.data?.find((country) => country.id === option)?.description ||
          "",
      }}
    />
  );
};
