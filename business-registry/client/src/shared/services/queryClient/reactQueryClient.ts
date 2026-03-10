import { AxiosError } from "axios";
import { MutationCache, QueryCache, QueryClient } from "@tanstack/react-query";
import { enqueueSnackbar } from "notistack";
import { ErrorResponse } from "src/shared/types/types";

const onErrorFunction = async (error: AxiosError<ErrorResponse>) => {
  enqueueSnackbar(error?.response?.data?.message ?? "", { variant: "error" });
};

const queryClient = new QueryClient({
  mutationCache: new MutationCache(),
  queryCache: new QueryCache(),
  defaultOptions: {
    queries: {
      refetchOnReconnect: false,
      refetchOnWindowFocus: false,
      retry: false,
    },
    mutations: {
      onError: async (error: any) => {
        await onErrorFunction(error);
      },
    },
  },
});

export { queryClient };
