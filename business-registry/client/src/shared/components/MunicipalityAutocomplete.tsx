import { Tooltip } from "@mui/material";
import { useTranslation } from "react-i18next";
import { useGetMunicipalities } from "src/shared/data-access/useGetMunicipalities";
import { AutocompleteElement } from "react-hook-form-mui";
import { CustomAutocompleteProps } from "src/shared/types/types";

export const MunicipalityAutocomplete = (props: CustomAutocompleteProps) => {
  const { isRequired, idForSearch } = props;
  const { t } = useTranslation();
  const { data, isFetching } = useGetMunicipalities(idForSearch ?? 0);

  return (
    <Tooltip
      title={
        !idForSearch ? t("Πρέπει να επιλέξετε Νομό για να επιλέξετε Δήμο") : ""
      }
      disableHoverListener={!!idForSearch}
      disableFocusListener={!!idForSearch}
      disableTouchListener={!!idForSearch}
    >
      <span style={{ width: "100%" }}>
        <AutocompleteElement
          loading={isFetching}
          label={t("Δήμος")}
          required={isRequired}
          name={"municipalityId"}
          options={data?.data?.map((municipality) => municipality.id) ?? []}
          autocompleteProps={{
            disabled: !idForSearch,
            sx: { width: "100%" },
            isOptionEqualToValue: (option, value) => option === value,
            getOptionLabel: (option) =>
              data?.data?.find((municipality) => municipality.id === option)
                ?.description || "",
          }}
        />
      </span>
    </Tooltip>
  );
};
