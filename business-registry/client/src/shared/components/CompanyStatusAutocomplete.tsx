import { useTranslation } from "react-i18next";
import { useGetCompanyStatuses } from "src/shared/data-access/useGetCompanyStatuses";
import { AutocompleteElement } from "react-hook-form-mui";
import { CustomAutocompleteProps } from "src/shared/types/types";

export const CompanyStatusAutocomplete = (props: CustomAutocompleteProps) => {
  const { isRequired } = props;
  const { t } = useTranslation();
  const { data, isFetching } = useGetCompanyStatuses();

  return (
    <AutocompleteElement
      label={t("Κατάσταση Επιχείρησης")}
      required={isRequired}
      loading={isFetching}
      name={"companyStatusId"}
      options={data?.data?.map((status) => status.id) ?? []}
      autocompleteProps={{
        sx: { width: "100%" },
        isOptionEqualToValue: (option, value) => option === value,
        getOptionLabel: (option) =>
          data?.data?.find((status) => status.id === option)?.description || "",
      }}
    />
  );
};
