import { useQuery } from "@tanstack/react-query";
import { searchPersons } from "src/pages/member/data-access/gateway";

export const useSearchPersons = () => {
  return useQuery({
    queryKey: ["searchPersons"],
    queryFn: () => searchPersons(),
  });
};
