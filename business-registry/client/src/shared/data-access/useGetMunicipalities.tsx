import { getMunicipalities } from "src/shared/data-access/gateway";
import { useQuery } from "@tanstack/react-query";

export const useGetMunicipalities = (prefectureId: number) => {
  return useQuery({
    queryKey: ["getMunicipalities"],
    queryFn: () => getMunicipalities(prefectureId),
  });
};
