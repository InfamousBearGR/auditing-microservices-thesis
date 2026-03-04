import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { updateCompany } from "src/pages/company/data-access/gateway";
import { enqueueSnackbar } from "notistack";

export const useUpdateCompany = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation({
    mutationKey: ["updateCompany"],
    mutationFn: updateCompany,
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: ["indexCompany", "viewCompany"],
      });
      return enqueueSnackbar(t("Επιτυχής ενημέρωση επιχείρησης!"), {
        variant: "success",
      });
    },
  });
};
