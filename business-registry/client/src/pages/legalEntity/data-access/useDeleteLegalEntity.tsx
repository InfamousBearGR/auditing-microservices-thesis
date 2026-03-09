import { useMutation, useQueryClient } from "@tanstack/react-query";
import { deleteLegalEntity } from "src/pages/legalEntity/data-access/gateway";
import { useTranslation } from "react-i18next";
import { enqueueSnackbar } from "notistack";

export const useDeleteLegalEntity = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation({
    mutationKey: ["deleteLegalEntity"],
    mutationFn: deleteLegalEntity,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["indexLegalEntity"] });
      return enqueueSnackbar(t("Επιτυχής διαγραφή Νομικού Προσώπου!"), {
        variant: "success",
      });
    },
  });
};
