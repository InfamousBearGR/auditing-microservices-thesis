import { useQuery } from "@tanstack/react-query";
import { getRegions } from "src/shared/data-access/gateway";

export const useGetRegions = () => {
  return useQuery({
    queryKey: ["getRegions"],
    queryFn: getRegions,
  });
}