import { useQuery } from "@tanstack/react-query";
import { searchLegalEntities } from "src/pages/member/data-access/gateway";

export const useSearchLegalEntities = () => {
  return useQuery({
    queryKey: ["searchLegalEntities"],
    queryFn: () => searchLegalEntities(),
  });
};
