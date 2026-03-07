import {MRT_RowData, MRT_TableOptions, useMaterialReactTable,} from "material-react-table";

export const useCustomMaterialTable = <TData extends MRT_RowData>(
  props: MRT_TableOptions<TData>,
) => {
  return useMaterialReactTable({
    ...props,
    layoutMode: "grid",
    defaultColumn: {
      minSize: 10,
      maxSize: 100,
    },
    muiTableBodyCellProps: {
      sx: {
        display: "flex",
        justifyContent: "start",
        wordBreak: "break-word",
        padding: "1rem .5rem",
      },
    },
    muiTableHeadCellProps: {
      sx: {
        display: "flex",
        justifyContent: "center",
        padding: ".5rem",
      },
    },
    enablePagination:
      (!!props?.manualPagination && !!props?.onPaginationChange) ||
      (!!props?.data?.length && props?.data?.length > 4),
  });
};
