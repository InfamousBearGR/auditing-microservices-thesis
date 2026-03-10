import { useTranslation } from "react-i18next";
import { useGetMemberRelations } from "src/shared/data-access/useGetMemberRelations";
import { AutocompleteElement } from "react-hook-form-mui";
import { CustomAutocompleteProps } from "src/shared/types/types";

export const MemberRelationAutocomplete = (props: CustomAutocompleteProps) => {
  const { isRequired } = props;
  const { t } = useTranslation();
  const { data, isFetching } = useGetMemberRelations();

  return (
    <AutocompleteElement
      label={t("Ιδιότητα")}
      loading={isFetching}
      required={isRequired}
      name={"memberRelationId"}
      options={data?.data?.map((relation) => relation.id) ?? []}
      autocompleteProps={{
        sx: { width: "100%" },
        isOptionEqualToValue: (option, value) => option === value,
        getOptionLabel: (option) =>
          data?.data?.find((relation) => relation.id === option)?.description ||
          "",
      }}
    />
  );
};
