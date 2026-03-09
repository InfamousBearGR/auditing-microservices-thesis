import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createPerson } from "src/pages/person/data-access/gateway";
import { enqueueSnackbar } from "notistack";
import { useTranslation } from "react-i18next";
import { useNavigate } from "@tanstack/react-router";

export const useCreatePerson = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation({
    mutationKey: ["createPerson"],
    mutationFn: createPerson,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["indexPerson"] });
      enqueueSnackbar(t("Επιτυχής εισαγωγή Φυσικού Προσώπου!"), {
        variant: "success",
      });
      await navigate({ to: "/person/index" });
    },
  });
};
