import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import TableCell, { tableCellClasses } from "@mui/material/TableCell";
import TableContainer from "@mui/material/TableContainer";
import TableRow from "@mui/material/TableRow";
import { Link, Typography } from "@mui/material";
import { Box } from "@mui/system";
import { DetailsProps, DetailsRow } from "./types";
import React, { useMemo } from "react";
import {
  defaultRenderArray,
  defaultRenderDates,
  defaultRenderObject,
} from "./utils";

export const Details = (props: DetailsProps) => {
  const {
    rows = [],
    title,
    renderArraysAsColumns = false,
    renderAsStripped = false,
    renderFirstRowsAsHeader = false,
    removeLines = false,
    renderDates = defaultRenderDates,
    renderArrays = defaultRenderArray,
    renderObject = defaultRenderObject,
  } = props;

  /** In case we want to render arrays as columns */
  const maxNumberOfColumns = useMemo(() => {
    if (!Array.isArray(rows)) return 0;
    return rows.reduce(
      (max: number, row: any) => Math.max(max, row?.value?.length ?? 0),
      0,
    );
  }, [rows]);

  const renderValue = (value: any) => {
    if (value instanceof Date) return renderDates(value);
    if (Array.isArray(value)) return renderArrays(value);
    if (typeof value === "object" && value !== null && "url" in value)
      return value.label;
    if (React.isValidElement(value)) return value;
    if (typeof value === "object" && value !== null) return renderObject(value);
    return value;
  };

  const renderCell = (
    value: any,
    index: number,
    renderBold?: boolean,
    isHeader?: boolean,
  ) => (
    <TableCell
      variant={index === 0 || isHeader ? "head" : "body"}
      scope="row"
      align={isHeader ? "center" : "left"}
      key={value}
      colSpan={isHeader ? 2 : 1}
      sx={{ borderBottom: isHeader ? "none" : null }}
    >
      {typeof value === "object" && value !== null && "url" in value ? (
        "externalLink" in value ? (
          <a href={renderValue(value.url)} target="_blank" rel="noreferrer">
            {renderValue(value)}
          </a>
        ) : (
          <Link
            fontWeight={renderFirstRowsAsHeader && index === 0 ? "650" : "500"}
          >
            {renderValue(value)}
          </Link>
        )
      ) : (
        <Typography
          fontWeight={
            renderFirstRowsAsHeader
              ? index === 0
                ? "650"
                : "500"
              : renderBold
                ? "bold"
                : "regular"
          }
        >
          {renderValue(value)}
        </Typography>
      )}
    </TableCell>
  );

  const renderEmptyCells = (numberOfCells: number) =>
    Array.from(Array(numberOfCells).keys()).map((x) => (
      <TableCell align="left" key={x}>
        <Typography />
      </TableCell>
    ));

  /** Render cells adding as many cells as the max number of columns */
  const renderValuesAsColumns = (row: any, indexRow: number) =>
    row.value.map((value: any) => [
      renderCell(value, indexRow),
      ...renderEmptyCells(maxNumberOfColumns - row.value.length),
    ]);

  const renderRow = (row: DetailsRow, index: number) => (
    <TableRow
      key={`row-${index}`}
      sx={{
        backgroundColor:
          renderAsStripped || row.name === "header" ? "#eeeeee" : "",
      }}
    >
      {row.name !== "header" &&
        row.name !== "objectArray" &&
        renderCell(row.name, index, true)}
      {renderArraysAsColumns && Array.isArray(row.value)
        ? renderValuesAsColumns(row, index)
        : renderCell(
            row.value,
            index,
            row.name === "header",
            row.name === "header" || row.name === "objectArray",
          )}
    </TableRow>
  );

  return (
    <Box display="flex" gap="10px" flexDirection="column">
      <Typography variant="h4" style={{ marginLeft: "10px" }}>
        {title}
      </Typography>
      <TableContainer sx={{ overflow: "auto" }} id="table-details">
        <Table
          size="small"
          aria-label="simple table"
          sx={{
            tableLayout: "fixed",
            [`& .${tableCellClasses.root}`]: {
              borderBottom: removeLines && "none",
            },
          }}
        >
          <TableBody>
            {(rows as DetailsRow[]).map((row, index) =>
              row.isHiddenRow ? null : renderRow(row, index + 1),
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
};
