import { viewPerson } from "src/pages/person/data-access/gateway";
import { useQuery } from "@tanstack/react-query";

export const useViewPerson = (id: number) => {
  return useQuery({
    queryKey: ["viewPerson", id],
    queryFn: () => viewPerson(id),
  });
};
