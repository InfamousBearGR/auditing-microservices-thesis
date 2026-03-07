import {useTranslation} from "react-i18next";
import {useMutation, useQueryClient} from "@tanstack/react-query";
import {updateCompany} from "src/pages/company/data-access/gateway";
import {enqueueSnackbar} from "notistack";
import {useNavigate} from "@tanstack/react-router";

export const useUpdateCompany = () => {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation({
    mutationKey: ["updateCompany"],
    mutationFn: updateCompany,
    onSuccess: async () => {
      await queryClient.invalidateQueries({
        queryKey: ["indexCompany", "viewCompany"],
      });
      enqueueSnackbar(t("Επιτυχής ενημέρωση επιχείρησης!"), {
        variant: "success",
      });
      await navigate({ to: "/company/index" });
    },
  });
};
