import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { updatePerson } from "src/pages/person/data-access/gateway";
import { enqueueSnackbar } from "notistack";
import { useNavigate } from "@tanstack/react-router";

export const useUpdatePerson = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation({
    mutationKey: ["updatePerson"],
    mutationFn: updatePerson,
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: ["indexPerson", "viewPerson"],
      });
      enqueueSnackbar(t("Επιτυχής ενημέρωση Φυσικού Προσώπου!"), {
        variant: "success",
      });
      await navigate({ to: "/person/index" });
    },
  });
};
