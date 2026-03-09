import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createLegalEntity } from "src/pages/legalEntity/data-access/gateway";
import { enqueueSnackbar } from "notistack";
import { useTranslation } from "react-i18next";
import { useNavigate } from "@tanstack/react-router";

export const useCreateLegalEntity = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation({
    mutationKey: ["createLegalEntity"],
    mutationFn: createLegalEntity,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["indexLegalEntity"] });
      enqueueSnackbar(t("Επιτυχής εισαγωγή Νομικού Προσώπου!"), {
        variant: "success",
      });
      await navigate({ to: "/legalEntity/index" });
    },
  });
};
