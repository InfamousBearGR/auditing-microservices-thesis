import { useQuery } from "@tanstack/react-query";
import { indexPerson } from "src/pages/person/data-access/gateway";

export const useIndexPerson = () => {
  return useQuery({
    queryKey: ["indexPerson"],
    queryFn: () => indexPerson(),
  });
};
