import { useMutation, useQueryClient } from "@tanstack/react-query";
import { deleteMember } from "src/pages/member/data-access/gateway";
import { useTranslation } from "react-i18next";
import { enqueueSnackbar } from "notistack";

export const useDeleteMember = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();

  return useMutation({
    mutationKey: ["deleteMember"],
    mutationFn: deleteMember,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["indexMember"] });
      return enqueueSnackbar(t("Επιτυχής διαγραφή Μέλους!"), {
        variant: "success",
      });
    },
  });
};
