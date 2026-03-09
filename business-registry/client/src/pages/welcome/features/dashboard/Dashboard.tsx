import {
  Box,
  Card,
  CardActionArea,
  CardContent,
  Typography,
} from "@mui/material";
import BusinessIcon from "@mui/icons-material/Business";
import PersonIcon from "@mui/icons-material/Person";
import AccountBalanceIcon from "@mui/icons-material/AccountBalance";
import { useNavigate } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

const dashboardItems = [
  {
    labelKey: "Επιχειρήσεις",
    icon: <BusinessIcon sx={{ fontSize: 64, color: "primary.main" }} />,
    path: "/company/index" as const,
  },
  {
    labelKey: "Φυσικά Πρόσωπα",
    icon: <PersonIcon sx={{ fontSize: 64, color: "primary.main" }} />,
    path: "/person/index" as const,
  },
  {
    labelKey: "Νομικά Πρόσωπα",
    icon: <AccountBalanceIcon sx={{ fontSize: 64, color: "primary.main" }} />,
    path: "/legalEntity/index" as const,
  },
];

export const Dashboard = () => {
  const navigate = useNavigate();
  const { t } = useTranslation();

  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "80vh",
        gap: 4,
        px: 2,
      }}
    >
      <Typography variant="h4" fontWeight={600} color="primary">
        {t("Κεντρικό Μενού")}
      </Typography>
      <Box
        sx={{
          display: "flex",
          flexWrap: "wrap",
          gap: 4,
          justifyContent: "center",
          alignItems: "stretch",
        }}
      >
        {dashboardItems.map((item) => (
          <Card
            key={item.path}
            elevation={4}
            sx={{
              width: 220,
              borderRadius: 3,
              transition: "transform 0.2s, box-shadow 0.2s",
              "&:hover": {
                transform: "translateY(-6px)",
                boxShadow: 8,
              },
            }}
          >
            <CardActionArea
              onClick={() => navigate({ to: item.path })}
              sx={{
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                justifyContent: "center",
                height: "100%",
                py: 4,
                px: 2,
              }}
            >
              <CardContent
                sx={{
                  display: "flex",
                  flexDirection: "column",
                  alignItems: "center",
                  gap: 2,
                }}
              >
                {item.icon}
                <Typography variant="h6" fontWeight={500} textAlign="center">
                  {t(item.labelKey)}
                </Typography>
              </CardContent>
            </CardActionArea>
          </Card>
        ))}
      </Box>
    </Box>
  );
};
