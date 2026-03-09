import { useMutation, useQueryClient } from "@tanstack/react-query";
import { deletePerson } from "src/pages/person/data-access/gateway";
import { useTranslation } from "react-i18next";
import { enqueueSnackbar } from "notistack";

export const useDeletePerson = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  return useMutation({
    mutationKey: ["deletePerson"],
    mutationFn: deletePerson,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["indexPerson"] });
      return enqueueSnackbar(t("Επιτυχής διαγραφή Φυσικού Προσώπου!"), {
        variant: "success",
      });
    },
  });
};
