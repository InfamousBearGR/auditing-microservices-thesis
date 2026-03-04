import {
  Box,
  Button,
  IconButton,
  InputAdornment,
  Typography,
} from "@mui/material";
import { useTranslation } from "react-i18next";
import { FormContainer, TextFieldElement, useForm } from "react-hook-form-mui";
import { useState } from "react";
import { Visibility, VisibilityOff } from "@mui/icons-material";
import PersonIcon from "@mui/icons-material/Person";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useLogin } from "src/pages/welcome/features/data-access/useLogin";
import { useAuth } from "src/shared/context/useAuth";
import { useNavigate } from "@tanstack/react-router";

export const LoginForm = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const loginSchema = z.object({
    username: z.string().min(1, t("Το όνομα χρήστη είναι υποχρεωτικό")),
    password: z.string().min(1, t("Ο κωδικός χρήστη είναι υποχρεωτικός")),
  });
  type LoginFormValues = z.infer<typeof loginSchema>;
  const formContext = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      username: "",
      password: "",
    },
  });
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const { mutate, isPending } = useLogin();
  const { authenticated, userHomePath } = useAuth();

  if (authenticated) {
    navigate({ to: userHomePath });
  }

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        gap: "1rem",
        width: "80vw",
        mx: "auto",
        mb: "2rem",
        alignItems: "center",
      }}
    >
      <Typography variant={"h3"}>{t("Είσοδος Χρήστη")}</Typography>
      <FormContainer
        formContext={formContext}
        onSuccess={(data) => mutate(data)}
      >
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: "1rem",
            mb: "2rem",
            width: "30vw",
            mt: "2rem",
          }}
        >
          <TextFieldElement
            fullWidth
            sx={{
              "& :-webkit-autofill": {
                transitionDelay: "9999s",
              },
            }}
            name={"username"}
            label={t("Όνομα Χρήστη")}
            required
          />
          <TextFieldElement
            fullWidth
            sx={{
              "& :-webkit-autofill": {
                transitionDelay: "9999s",
              },
              "& .MuiFormLabel-root": {
                fontSize: "1.1rem",
              },
            }}
            name={"password"}
            label={t("Κωδικός Χρήστη")}
            required
            type={showPassword ? "text" : "password"}
            slotProps={{
              input: {
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      onClick={() => setShowPassword((prev) => !prev)}
                      edge="end"
                    >
                      {showPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              },
            }}
          />
          <Button
            loading={isPending}
            startIcon={<PersonIcon />}
            variant="contained"
            type="submit"
          >
            {t("Είσοδος")}
          </Button>
        </Box>
      </FormContainer>
    </Box>
  );
};
