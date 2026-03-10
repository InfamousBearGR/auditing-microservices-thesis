import { useTranslation } from "react-i18next";
import { useNavigate, useParams } from "@tanstack/react-router";
import { useViewCompanyCapital } from "src/pages/companyCapital/data-access/useViewCompanyCapital";
import { enqueueSnackbar } from "notistack";
import { useUpdateCompanyCapital } from "src/pages/companyCapital/data-access/useUpdateCompanyCapital";
import { FormContainer, useForm, UseFormReturn } from "react-hook-form-mui";
import {
  CompanyCapitalValidationSchema,
  getCompanyCapitalValidationSchema,
} from "src/pages/companyCapital/features/shared/validation/validationSchema";
import { zodResolver } from "@hookform/resolvers/zod";
import { useEffect } from "react";
import { Box } from "@mui/system";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";
import { Button, Typography } from "@mui/material";
import { CompanyCapitalForm } from "src/pages/companyCapital/features/shared/CompanyCapitalForm";
import EditIcon from "@mui/icons-material/Edit";

export const Edit = () => {
  const { t } = useTranslation();
  const { id: companyIdParam } = useParams({
    from: "/company/$id/capital/edit",
  });
  const navigate = useNavigate();

  const companyId = companyIdParam ? Number(companyIdParam) : 0;

  if (!companyId) {
    navigate({ to: "/company/index" });
  }

  const { data, isFetching, isError } = useViewCompanyCapital(companyIdParam!);

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση του κεφαλαίου"), {
      variant: "error",
    });
    navigate({ to: "/company/$id/details", params: { id: companyIdParam } });
  }

  const { mutate, isPending } = useUpdateCompanyCapital(companyIdParam);

  const formContext: UseFormReturn<CompanyCapitalValidationSchema> = useForm({
    resolver: zodResolver(getCompanyCapitalValidationSchema(t)),
    defaultValues: {
      changeReason: "",
      totalAmount: data?.data?.totalAmount,
      currencyId: data?.data?.currency.id,
      companyId: companyId,
      stocks:
        data?.data?.stocks.map((stock) => ({
          id: stock.id,
          stockTypeId: stock.stockType.id,
          amount: stock.amount,
          nominalPrice: stock.nominalPrice.toString(),
          companyId: companyId,
          toBeDeleted: false,
        })) ?? [],
    },
  });

  useEffect(() => {
    if (data?.data && !isFetching) {
      formContext.reset({
        changeReason: "",
        companyId: companyId,
        totalAmount: data.data.totalAmount,
        currencyId: data.data.currency.id,
        stocks: data.data.stocks.map((stock) => ({
          id: stock.id,
          stockTypeId: stock.stockType.id,
          amount: stock.amount,
          nominalPrice: stock.nominalPrice.toString(),
          companyId: companyId,
          toBeDeleted: false,
        })),
      });
    }
  }, [companyId, data?.data, formContext, isFetching]);

  const extractErrors = (
    errors: Record<string, unknown>,
    path: string = "",
  ): void => {
    Object.entries(errors).forEach(([key, value]: [string, unknown]) => {
      const currentPath = path ? `${path}.${key}` : key;
      console.debug(currentPath);
      if (
        value &&
        typeof value === "object" &&
        "message" in value &&
        value.message
      ) {
        // Direct error message
        enqueueSnackbar(String(value.message), {
          variant: "error",
        });
      } else if (value && typeof value === "object") {
        // Nested error object, recurse
        extractErrors(value as Record<string, unknown>, currentPath);
      }
    });
  };

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        gap: "1rem",
        width: "100%",
      }}
    >
      {isFetching ? (
        <CustomCircularProgressBar />
      ) : (
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: "1rem",
            width: "100%",
          }}
        >
          <Typography variant={"h5"}>
            {t("Επεξεργασία Κεφαλαίου και Μετοχών")}
          </Typography>
          <FormContainer
            formContext={formContext}
            onSuccess={(data) =>
              mutate({
                data: {
                  ...data,
                  companyId: companyId!,
                  totalAmount: data.totalAmount.trim(),
                  stocks:
                    data?.stocks?.map((stock) => ({
                      ...stock,
                      nominalPrice: stock.nominalPrice.trim(),
                    })) ?? [],
                },
              })
            }
            onError={(formError) => {
              extractErrors(formError);
            }}
          >
            <Box
              sx={{
                display: "flex",
                flexDirection: "column",
                gap: "1rem",
                width: "100%",
              }}
            >
              <CompanyCapitalForm
                companyId={companyId}
                isFetching={isFetching}
              />
              <Box
                sx={{
                  display: "flex",
                  flexDirection: "row",
                  gap: "1rem",
                  width: "100%",
                  justifyContent: "flex-end",
                }}
              >
                <Button
                  startIcon={<EditIcon />}
                  variant={"contained"}
                  loading={isPending}
                  type={"submit"}
                >
                  {t("Υποβολή")}
                </Button>
              </Box>
            </Box>
          </FormContainer>
        </Box>
      )}
    </Box>
  );
};
