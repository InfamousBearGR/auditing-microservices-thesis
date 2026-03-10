import { viewCompanyCapital } from "src/pages/companyCapital/data-access/gateway";
import { useQuery } from "@tanstack/react-query";

export const useViewCompanyCapital = (id: number) => {
  return useQuery({
    queryKey: ["viewCompanyCapital", id],
    queryFn: () => viewCompanyCapital(id),
  });
};
