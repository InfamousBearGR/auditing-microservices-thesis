import React from "react";
import { format } from "date-fns";

export const defaultRenderObject = (object: any) => {
  return JSON.stringify(object);
};

export const defaultRenderArray = (array: any[]) => {
  if (array.length > 0 && React.isValidElement(array[0])) {
    return <>{array}</>;
  }
  return array.join(", ");
};

export const defaultRenderDates = (date: Date) => {
  return format(date, "dd/MM/yyyy");
};
