import { useQuery } from "@tanstack/react-query";
import { getMemberRelations } from "src/shared/data-access/gateway";

export const useGetMemberRelations = () => {
    return useQuery({
      queryKey: ["getMemberRelations"],
      queryFn: getMemberRelations,
    });
}