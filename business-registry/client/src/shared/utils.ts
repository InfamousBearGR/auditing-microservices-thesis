import { parse, format } from "date-fns";

export const stringToDate = (
  dateString: string | undefined,
): Date | undefined => {
  if (!dateString) return undefined;
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

export const validateAfm = (afm: string): boolean => {
  if (afm.length !== 9) return false;
  if (!/^\d+$/.test(afm)) return false;
  if (afm === "000000000") return false;

  let sum = 0;
  for (let i = 0; i < 8; i++) {
    sum += parseInt(afm[i]) * Math.pow(2, 8 - i);
  }

  const calc = sum % 11;
  const d9 = parseInt(afm[8]);
  return calc % 10 === d9;
};
