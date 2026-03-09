import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { updateLegalEntity } from "src/pages/legalEntity/data-access/gateway";
import { enqueueSnackbar } from "notistack";
import { useNavigate } from "@tanstack/react-router";

export const useUpdateLegalEntity = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation({
    mutationKey: ["updateLegalEntity"],
    mutationFn: updateLegalEntity,
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: ["indexLegalEntity", "viewLegalEntity"],
      });
      enqueueSnackbar(t("Επιτυχής ενημέρωση Νομικού Προσώπου!"), {
        variant: "success",
      });
      await navigate({ to: "/legalEntity/index" });
    },
  });
};
