import { useQuery } from "@tanstack/react-query";
import { getCountries } from "src/shared/data-access/gateway";

export const useGetCountries = () => {
  return useQuery({
    queryKey: ["getCountries"],
    queryFn: getCountries,
  });
}