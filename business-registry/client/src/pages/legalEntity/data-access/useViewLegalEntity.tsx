import { viewLegalEntity } from "src/pages/legalEntity/data-access/gateway";
import { useQuery } from "@tanstack/react-query";

export const useViewLegalEntity = (id: number) => {
  return useQuery({
    queryKey: ["viewLegalEntity", id],
    queryFn: () => viewLegalEntity(id),
  });
};
