import {useTranslation} from "react-i18next";
import {useGetStockTypes} from "src/shared/data-access/useGetStockTypes";
import {AutocompleteElement} from "react-hook-form-mui";
import {CustomAutocompleteProps} from "src/shared/types/types";

export const StockTypeAutocomplete = (props: CustomAutocompleteProps) => {
  const { isRequired } = props;
  const { t } = useTranslation();
  const { data, isFetching } = useGetStockTypes();

  return (
    <AutocompleteElement
      loading={isFetching}
      label={t("Τύπος Μετοχής")}
      required={isRequired}
      name={"stockTypeId"}
      options={data?.data?.map((stockType) => stockType.id) ?? []}
      autocompleteProps={{
        sx: { width: "100%" },
        isOptionEqualToValue: (option, value) => option === value,
        getOptionLabel: (option) =>
          data?.data?.find((stockType) => stockType.id === option)
            ?.description || "",
      }}
    />
  );
};
