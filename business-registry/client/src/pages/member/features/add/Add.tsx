import { useTranslation } from "react-i18next";
import { FormContainer, useForm } from "react-hook-form-mui";
import { zodResolver } from "@hookform/resolvers/zod";
import { getMemberValidationSchema } from "src/pages/member/features/shared/validation/validationSchema";
import { useCreateMember } from "src/pages/member/data-access/useCreateMember";
import { Box } from "@mui/system";
import { Button, Typography } from "@mui/material";
import { dateToString } from "src/shared/utils";
import { MemberForm } from "src/pages/member/features/shared/MemberForm";
import EditIcon from "@mui/icons-material/Edit";
import { useNavigate, useParams } from "@tanstack/react-router";

export const Add = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { id: idParam } = useParams({ from: "/company/$id/member/add" });
  const companyId = idParam ? Number(idParam) : undefined;

  if (!companyId) {
    navigate({ to: "/company/index" });
  }

  const { mutate, isPending } = useCreateMember(companyId!);

  const formContext = useForm({
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

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        gap: "1rem",
        width: "100%",
      }}
    >
      <Typography variant={"h5"}>{t("Εισαγωγή Εταίρου")}</Typography>
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          gap: "1rem",
          width: "100%",
        }}
      >
        <FormContainer
          formContext={formContext}
          onSuccess={(data) =>
            mutate({
              data: {
                ...data,
                companyId: companyId!,
                dateFrom: dateToString(data.dateFrom),
                dateTo: dateToString(data.dateTo),
                personId: data.personId ?? null,
                legalEntityId: data.legalEntityId ?? null,
                representativeOfMemberId: data.representativeOfMemberId ?? null,
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
    </Box>
  );
};
