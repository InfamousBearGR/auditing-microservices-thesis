import {CSSProperties, JSX} from "react";

type PrimitiveCellValues = string | number | boolean | null | undefined;

interface UrlObject {
  url: string;
  label: string;
}
export interface DetailsRow {
  name: string | UrlObject | JSX.Element;
  value:
    | string
    | Date
    | PrimitiveCellValues[][]
    | Array<any>
    | JSX.Element
    | UrlObject
    | undefined
    | string[];
  refValue?: string;
  isHiddenRow?: boolean;
}

export interface RenderFunctions {
  renderDates?: (date: Date) => string;
  renderObject?: (object: any) => string;
  renderArrays?: (array: any[]) => string | JSX.Element | JSX.Element[];
}

export interface DetailsProps extends RenderFunctions {
  rows?: DetailsRow[] | DetailsRow[][];
  title?: string;
  style?: CSSProperties;
  renderArraysAsColumns?: boolean;
  renderAsStripped?: boolean;
  renderFirstRowsAsHeader?: boolean;
  removeLines?: boolean;
}
