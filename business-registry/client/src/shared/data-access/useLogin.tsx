import { useMutation, useQueryClient } from "@tanstack/react-query";
import { login } from "src/shared/data-access/gateway";

export const useLogin = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: login,
    mutationKey: ["login"],
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["checkUserSession"] });
      queryClient.removeQueries();
    },
  });
};
