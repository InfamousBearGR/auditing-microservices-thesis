import {useMutation, useQueryClient} from "@tanstack/react-query";
import {login} from "src/pages/welcome/features/data-access/gateway";
import {useNavigate} from "@tanstack/react-router";

export const useLogin = () => {
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  return useMutation({
    mutationFn: login,
    mutationKey: ["login"],
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["checkUserSession"] });
      queryClient.removeQueries();
      await navigate({ to: "/company/index" });
    },
  });
};
