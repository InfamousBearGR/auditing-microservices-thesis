import {useQuery} from "@tanstack/react-query";
import {getCompanyStatuses} from "src/shared/data-access/gateway";

export const useGetCompanyStatuses = () => {
  return useQuery({
    queryKey: ["getCompanyStatuses"],
    queryFn: getCompanyStatuses,
  });
}