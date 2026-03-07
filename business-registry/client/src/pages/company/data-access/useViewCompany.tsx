import {viewCompany} from "src/pages/company/data-access/gateway";
import {useQuery} from "@tanstack/react-query";

export const useViewCompany = (id: number) => {
  return useQuery({
    queryKey: ["viewCompany", id],
    queryFn: () => viewCompany(id),
  });
};
