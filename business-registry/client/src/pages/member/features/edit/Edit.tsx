import { useTranslation } from "react-i18next";
import { useNavigate, useParams } from "@tanstack/react-router";
import { useViewMember } from "src/pages/member/data-access/useViewMember";
import { enqueueSnackbar } from "notistack";
import { CustomCircularProgressBar } from "src/shared/components/CustomCircularProgressBar";
import { Box } from "@mui/system";
import { Button, Typography } from "@mui/material";
import { useUpdateMember } from "src/pages/member/data-access/useUpdateMember";
import {
  MemberValidationSchema,
  getMemberValidationSchema,
} from "src/pages/member/features/shared/validation/validationSchema";
import { zodResolver } from "@hookform/resolvers/zod";
import { FormContainer, useForm, UseFormReturn } from "react-hook-form-mui";
import { useEffect } from "react";
import EditIcon from "@mui/icons-material/Edit";
import { MemberForm } from "src/pages/member/features/shared/MemberForm";
import { dateToString, stringToDate } from "src/shared/utils";

export const Edit = () => {
  const { t } = useTranslation();
  const { id: companyIdParam, memberId: memberIdParam } = useParams({
    from: "/company/$id/member/edit/$memberId",
  });
  const navigate = useNavigate();

  const companyId = companyIdParam ? Number(companyIdParam) : undefined;
  const memberId = memberIdParam ? Number(memberIdParam) : undefined;

  if (!companyId || !memberId) {
    navigate({ to: "/company/index" });
  }

  const { data, isLoading, isError } = useViewMember(memberId!);

  if (isError) {
    enqueueSnackbar(t("Σφάλμα κατά τη φόρτωση του Εταίρου"), {
      variant: "error",
    });
    navigate({
      to: `/company/$id/member/index`,
      params: { id: String(companyId) },
    });
  }

  const { mutate, isPending } = useUpdateMember(companyId!);

  const formContext: UseFormReturn<MemberValidationSchema> = useForm({
    resolver: zodResolver(getMemberValidationSchema(t)),
    defaultValues: {
      active: false,
      dateFrom: undefined,
      dateTo: undefined,
      percentageOfOwnership: "",
      personId: null,
      legalEntityId: null,
      representativeOfMemberId: null,
      representedIndividual: false,
      representedTogether: false,
      memberRelationId: undefined,
      changeReason: "",
    },
  });

  useEffect(() => {
    if (data?.data && !isLoading) {
      formContext.reset({
        active: data.data.active,
        dateFrom: stringToDate(data.data.dateFrom),
        dateTo: stringToDate(data.data.dateTo),
        percentageOfOwnership: data.data.percentageOfOwnership,
        personId: data.data.person?.id ?? null,
        legalEntityId: data.data.legalEntity?.id ?? null,
        representativeOfMemberId: data.data.representativeOfMember?.id ?? null,
        representedIndividual: data.data.representedIndividual,
        representedTogether: data.data.representedTogether,
        memberRelationId: data.data.memberRelation.id,
        changeReason: "",
      });
    }
  }, [data?.data, formContext, isLoading]);

  const memberName = data?.data?.person
    ? `${data.data.person.name} ${data.data.person.surname}`
    : (data?.data?.legalEntity?.businessName ?? "");

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        gap: "1rem",
        width: "100%",
      }}
    >
      {isLoading ? (
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
          <Typography
            variant={"h5"}
          >{`${t("Επεξεργασία Εταίρου")}: ${memberName}`}</Typography>
          <FormContainer
            formContext={formContext}
            onSuccess={(data) =>
              mutate({
                id: memberId!,
                data: {
                  ...data,
                  companyId: companyId!,
                  dateFrom: dateToString(data.dateFrom),
                  dateTo: dateToString(data.dateTo),
                  personId: data.personId ?? null,
                  legalEntityId: data.legalEntityId ?? null,
                  representativeOfMemberId:
                    data.representativeOfMemberId ?? null,
                },
              })
            }
          >
            <Box
              sx={{
                display: "flex",
                flexDirection: "column",
                gap: "1rem",
                width: "100%",
              }}
            >
              <MemberForm />
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
