import {useQuery} from "@tanstack/react-query";
import {getLegalTypes} from "src/shared/data-access/gateway";

export const useGetLegalTypes = () => {
  return useQuery({
    queryKey: ["getLegalTypes"],
    queryFn: getLegalTypes,
  });
};
