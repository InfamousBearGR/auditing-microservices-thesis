import { useQuery } from "@tanstack/react-query";
import { viewMember } from "src/pages/member/data-access/gateway";

export const useViewMember = (id: number) => {
  return useQuery({
    queryKey: ["viewMember", id],
    queryFn: () => viewMember(id),
  });
};
