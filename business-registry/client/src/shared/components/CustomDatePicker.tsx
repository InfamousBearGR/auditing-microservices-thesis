import { useEffect } from "react";
import { FieldValues, useFormContext, useFormState } from "react-hook-form-mui";
import { isValid, parse } from "date-fns";
import {
  DatePickerElement,
  DatePickerElementProps,
} from "react-hook-form-mui/date-pickers";

interface CustomDatePickerProps extends DatePickerElementProps<
  FieldValues,
  string,
  Date
> {
  displayPattern?: string;
}

export const CustomDatePicker = (props: CustomDatePickerProps) => {
  const { displayPattern = "dd/MM/yyyy", name, ...datePickerProps } = props;

  const formContext = useFormContext();
  const { defaultValues } = useFormState();

  useEffect(() => {
    if (!name) return;

    const currentValue = formContext.watch(name);
    if (currentValue) {
      if (typeof currentValue === "string") {
        const parsedDate = parse(currentValue, "yyyy-MM-dd", new Date());
        if (isValid(parsedDate)) {
          formContext.setValue(name, parsedDate, { shouldValidate: true });
        }
      }
    } else {
      formContext.setValue(name, undefined);
    }
  }, [defaultValues]);

  return (
    <DatePickerElement
      {...datePickerProps}
      name={name}
      format={datePickerProps?.format || displayPattern}
      slotProps={{
        ...datePickerProps.slotProps,
        field: {
          ...datePickerProps.slotProps?.field,
          clearable: true,
          onClear: () => formContext.setValue(name, undefined),
        },
      }}
    />
  );
};
