import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createCompany } from "src/pages/company/data-access/gateway";
import { enqueueSnackbar } from "notistack";
import { useTranslation } from "react-i18next";
import { useNavigate } from "@tanstack/react-router";

export const useCreateCompany = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation({
    mutationKey: ["createCompany"],
    mutationFn: createCompany,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["indexCompany"] });
      enqueueSnackbar(t("Επιτυχής εισαγωγή επιχείρησης!"), {
        variant: "success",
      });
      await navigate({ to: "/company/index" });
    },
  });
};
