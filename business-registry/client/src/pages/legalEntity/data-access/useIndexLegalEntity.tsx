import { useQuery } from "@tanstack/react-query";
import { indexLegalEntity } from "src/pages/legalEntity/data-access/gateway";

export const useIndexLegalEntity = () => {
  return useQuery({
    queryKey: ["indexLegalEntity"],
    queryFn: () => indexLegalEntity(),
  });
};
