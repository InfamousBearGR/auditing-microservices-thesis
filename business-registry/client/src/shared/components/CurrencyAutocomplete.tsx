import { useTranslation } from "react-i18next";
import { useGetCurrencies } from "src/shared/data-access/useGetCurrencies";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";
import { AutocompleteElement } from "react-hook-form-mui";
import { CustomAutocompleteProps } from "src/shared/types/types";

export const CurrencyAutocomplete = (props: CustomAutocompleteProps) => {
  const { isRequired } = props;
  const { t } = useTranslation();
  const { data, isFetching } = useGetCurrencies();

  return (
    <AutocompleteElement
      loading={isFetching}
      label={t("Νόμισμα")}
      required={isRequired}
      name={"currencyId"}
      options={data?.data?.map((currency) => currency.id) ?? []}
      autocompleteProps={{
        sx: { width: "100%" },
        isOptionEqualToValue: (option, value) => option === value,
        getOptionLabel: (option) =>
          data?.data?.find((currency) => currency.id === option)?.description ||
          "",
      }}
    />
  );
};
