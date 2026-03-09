import { useTranslation } from "react-i18next";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { updateMember } from "src/pages/member/data-access/gateway";
import { enqueueSnackbar } from "notistack";
import { useNavigate } from "@tanstack/react-router";

export const useUpdateMember = (companyId: number) => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation({
    mutationKey: ["updateMember"],
    mutationFn: updateMember,
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: ["indexMember", "viewMember"],
      });
      enqueueSnackbar(t("Επιτυχής ενημέρωση Μέλους!"), {
        variant: "success",
      });
      await navigate({
        to: "/company/$id/member/index",
        params: { id: String(companyId) },
      });
    },
  });
};
