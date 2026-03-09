import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createMember } from "src/pages/member/data-access/gateway";
import { enqueueSnackbar } from "notistack";
import { useTranslation } from "react-i18next";
import { useNavigate } from "@tanstack/react-router";

export const useCreateMember = (companyId: number) => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation({
    mutationKey: ["createMember"],
    mutationFn: createMember,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["indexMember"] });
      enqueueSnackbar(t("Επιτυχής εισαγωγή Μέλους!"), {
        variant: "success",
      });
      await navigate({
        to: "/company/$id/member/index",
        params: { id: String(companyId) },
      });
    },
  });
};
