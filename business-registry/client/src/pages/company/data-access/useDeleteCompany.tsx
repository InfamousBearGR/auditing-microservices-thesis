import {useMutation, useQueryClient} from "@tanstack/react-query";
import {deleteCompany} from "src/pages/company/data-access/gateway";
import {useTranslation} from "react-i18next";
import {enqueueSnackbar} from "notistack";

export const useDeleteCompany = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  return useMutation({
    mutationKey: ["deleteCompany"],
    mutationFn: deleteCompany,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["indexCompany"] });
      return enqueueSnackbar(t("Επιτυχής διαγραφή επιχείρησης!"), {
        variant: "success",
      });
    },
  });
};
