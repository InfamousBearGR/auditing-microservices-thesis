import { useQuery } from "@tanstack/react-query";
import { indexMember } from "src/pages/member/data-access/gateway";

export const useIndexMember = (companyId: number) => {
  return useQuery({
    queryKey: ["indexMember", companyId],
    queryFn: () => indexMember(companyId),
  });
};
