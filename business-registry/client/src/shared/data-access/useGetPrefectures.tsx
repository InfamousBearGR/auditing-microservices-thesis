import {useQuery} from "@tanstack/react-query";
import {getPrefectures} from "src/shared/data-access/gateway";

export const useGetPrefectures = (regionId: number) => {
  return useQuery({
    queryKey: ["getPrefectures", regionId],
    queryFn: () => getPrefectures(regionId),
    enabled: !!regionId,
  });
};
