import { Tooltip } from "@mui/material";
import { useTranslation } from "react-i18next";
import { useGetPrefectures } from "src/shared/data-access/useGetPrefectures";
import { AutocompleteElement } from "react-hook-form-mui";
import { CustomAutocompleteProps } from "src/shared/types/types";

export const PrefectureAutocomplete = (props: CustomAutocompleteProps) => {
  const { isRequired, idForSearch } = props;
  const { t } = useTranslation();
  const { data, isFetching } = useGetPrefectures(idForSearch ?? 0);

  return (
    <Tooltip
      title={
        !idForSearch
          ? t("Πρέπει να επιλέξετε Περιφέρεια για να επιλέξετε Νομό")
          : ""
      }
      disableHoverListener={!!idForSearch}
      disableFocusListener={!!idForSearch}
      disableTouchListener={!!idForSearch}
    >
      <span style={{ width: "100%" }}>
        <AutocompleteElement
          label={t("Νομός")}
          required={isRequired}
          loading={isFetching}
          name={"prefectureId"}
          options={data?.data?.map((prefecture) => prefecture.id) ?? []}
          autocompleteProps={{
            disabled: !idForSearch,
            sx: { width: "100%" },
            isOptionEqualToValue: (option, value) => option === value,
            getOptionLabel: (option) =>
              data?.data?.find((prefecture) => prefecture.id === option)
                ?.description || "",
          }}
        />
      </span>
    </Tooltip>
  );
};
