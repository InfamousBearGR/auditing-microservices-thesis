import { useQuery } from "@tanstack/react-query";
import { indexCompany } from "src/pages/company/data-access/gateway";

export const useIndexCompany = (
  companyStatusId?: number,
  legalTypeId?: number,
) => {
  return useQuery({
    queryKey: ["indexCompany"],
    queryFn: () => indexCompany(companyStatusId, legalTypeId),
  });
};
