import {getCurrencies} from "src/shared/data-access/gateway";
import {useQuery} from "@tanstack/react-query";

export const useGetCurrencies = () => {
  return useQuery({
    queryKey: ["getCurrencies"],
    queryFn: getCurrencies,
  });
};
