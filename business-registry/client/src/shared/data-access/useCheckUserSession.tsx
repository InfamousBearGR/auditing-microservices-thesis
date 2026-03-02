import { useQuery } from "@tanstack/react-query";
import { checkUserSession } from "src/shared/data-access/gateway";

export const useCheckUserSession = () => {
  const isError502Page = window.location.pathname === "/error502";
  return useQuery({
    queryFn: checkUserSession,
    queryKey: ["checkUserSession"],
    retry: isError502Page,
    retryDelay: 5000,
  });
};
