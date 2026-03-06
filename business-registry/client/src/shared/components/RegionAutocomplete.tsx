import { useTranslation } from "react-i18next";
import { useGetRegions } from "src/shared/data-access/useGetRegions";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";
import { AutocompleteElement } from "react-hook-form-mui";
import { CustomAutocompleteProps } from "src/shared/types/types";

export const RegionAutocomplete = (props: CustomAutocompleteProps) => {
  const { isRequired } = props;
  const { t } = useTranslation();
  const { data, isFetching } = useGetRegions();

  return (
    <AutocompleteElement
      loading={isFetching}
      label={t("Περιφέρεια")}
      required={isRequired}
      name={"regionId"}
      options={data?.data?.map((region) => region.id) ?? []}
      autocompleteProps={{
        sx: { width: "100%" },
        isOptionEqualToValue: (option, value) => option === value,
        getOptionLabel: (option) =>
          data?.data?.find((region) => region.id === option)?.description || "",
      }}
    />
  );
};
