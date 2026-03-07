import {useQuery} from "@tanstack/react-query";
import {getStockTypes} from "src/shared/data-access/gateway";

export const useGetStockTypes = () => {
  return useQuery({
    queryKey: ["getStockTypes"],
    queryFn: getStockTypes,
  });
};
