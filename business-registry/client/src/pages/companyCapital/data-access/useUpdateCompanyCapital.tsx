import { useMutation, useQueryClient } from "@tanstack/react-query";
import { updateCompanyCapital } from "src/pages/companyCapital/data-access/gateway";
import { enqueueSnackbar } from "notistack";
import { useTranslation } from "react-i18next";
import { useNavigate } from "@tanstack/react-router";

export const useUpdateCompanyCapital = (id: number) => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation({
    mutationKey: ["updateCompanyCapital"],
    mutationFn: updateCompanyCapital,
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: ["viewCompanyCapital"],
      });
      enqueueSnackbar(t("Επιτυχής ενημέρωση επιχείρησης!"), {
        variant: "success",
      });
      await navigate({ to: "/company/$id/capital/view", params: { id: id } });
    },
  });
};
