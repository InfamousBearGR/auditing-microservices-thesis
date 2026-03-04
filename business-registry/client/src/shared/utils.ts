import { parse, format } from "date-fns";

export const stringToDate = (dateString: string): Date => {
  return parse(dateString, "yyyy-MM-dd", new Date());
};

export const dateToString = (date: Date): string => {
  return format(date, "yyyy-MM-dd");
};

export const stringToFormatDate = (dateString: string | undefined): string => {
  if (!dateString) return "";
  const date = parse(dateString, "yyyy-MM-dd", new Date());
  return format(date, "dd/MM/yyyy");
};
