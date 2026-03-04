import { useQuery } from "@tanstack/react-query";
import { indexCompany } from "src/pages/company/data-access/gateway";

export const useIndexCompany = () => {
  return useQuery({
    queryKey: ["indexCompany"],
    queryFn: indexCompany,
  });
};
