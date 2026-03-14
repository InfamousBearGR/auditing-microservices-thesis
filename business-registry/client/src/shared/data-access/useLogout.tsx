import { useMutation, useQueryClient } from "@tanstack/react-query";
import { logout } from "src/shared/data-access/gateway";
import { useNavigate } from "@tanstack/react-router";
import { useAuth } from "src/shared/context/useAuth";

export const useLogout = () => {
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const { setUserCantAccess } = useAuth();
  return useMutation({
    mutationFn: logout,
    mutationKey: ["logout"],
    onSuccess: async () => {
      localStorage.removeItem("userInfo");
      await queryClient.invalidateQueries({ queryKey: ["checkUserSession"] });
      setUserCantAccess(true);
      await navigate({ to: "/login" });
    },
  });
};
