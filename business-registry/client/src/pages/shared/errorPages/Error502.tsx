import {Box, Typography} from "@mui/material";
import React from "react";
import {useTranslation} from "react-i18next";
import {ErrorOutline} from "@mui/icons-material";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import {useAuth} from "src/shared/context/useAuth";
import {useCheckUserSession} from "src/shared/data-access/useCheckUserSession";
import {useNavigate} from "@tanstack/react-router";

export const Error502 = () => {
  const { isSuccess, isError, error } = useCheckUserSession();
  const { t } = useTranslation();
  const { userHomePath } = useAuth();

  const navigate = useNavigate();

  if (isSuccess) {
    navigate({ to: userHomePath });
  }
  console.debug(error);
  if (isError) {
  }

  return (
    <Box
      sx={{
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        height: "80vh",
        width: "100%",
        padding: 0,
        flexDirection: "column",
        position: "relative",
        gap: "6rem",
      }}
    >
      <Box
        sx={{
          position: "relative",
          display: "inline-block",
          right: "2rem",
          width: "50px",
          height: "50px",
        }}
      >
        <SettingsOutlinedIcon
          sx={{
            fontSize: 150,
            color: "#e2e8f0",
            position: "absolute",
            animation: "spin 15s linear infinite",
          }}
        />

        <ErrorOutline
          sx={{
            fontSize: 60,
            position: "absolute",
            color: "#94a3b8",
            top: "1.27em",
            left: "1.25em",
            transform: "translate(-50%, -50%)",
            backgroundColor: "#e2e8f0",
            borderRadius: "50%",
          }}
        />
        <style>
          {`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}
        </style>
      </Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          gap: 2,
          justifyContent: "center",
          alignItems: "center",
        }}
      >
        <Typography variant="h4" sx={{ mt: 2, textAlign: "center" }}>
          {t("Το σύστημα είναι προσωρινά μη διαθέσιμο")}
        </Typography>
        <Typography
          variant="body1"
          sx={{
            maxWidth: "60%",
            textAlign: "center",
            color: "grey",
            fontSize: 17,
          }}
        >
          {t(
            "Αυτή την στιγμή πραγματοποιούνται εργασίες αναβάθμισης για τη βελτίωση των υπηρεσιών μας. Το σύστημα θα είναι και πάλι διαθέσιμο σύντομα.",
          )}
        </Typography>
      </Box>
    </Box>
  );
};
