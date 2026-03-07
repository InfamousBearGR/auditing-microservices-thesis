import {useMutation, useQueryClient} from "@tanstack/react-query";
import {logout} from "src/shared/data-access/gateway";
import {useNavigate} from "@tanstack/react-router";

export const useLogout = () => {
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  return useMutation({
    mutationFn: logout,
    mutationKey: ["logout"],
    onSuccess: async () => {
      localStorage.removeItem("userInfo");
      await queryClient.invalidateQueries({ queryKey: ["checkUserSession"] });
      await navigate({ to: "/login" });
    },
  });
};
