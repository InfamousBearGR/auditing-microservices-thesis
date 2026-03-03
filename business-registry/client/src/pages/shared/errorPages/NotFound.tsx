import { Box, Typography, Button, Stack } from "@mui/material";
import {
  Home as HomeIcon,
  SearchOff as SearchOffIcon,
} from "@mui/icons-material";
import { useAuth } from "src/shared/context/useAuth";
import { useTranslation } from "react-i18next";
import { useNavigate } from "@tanstack/react-router";

function NotFoundPage() {
  const { userHomePath } = useAuth();
  const navigate = useNavigate();
  const { t } = useTranslation();

  return (
    <>
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          height: "90vh",
          textAlign: "center",
          p: 2,
        }}
      >
        <Stack direction="row" spacing={2} sx={{ mb: 2 }}>
          <SearchOffIcon sx={{ fontSize: 200, color: "text.secondary" }} />
        </Stack>
        <Typography variant="h4" component="h1" gutterBottom>
          {t("Ωχ! Η σελίδα δεν βρέθηκε.")}
        </Typography>
        <Typography variant="body1">
          {t(
            "Ψάξαμε παντού, αλλά δεν μπορέσαμε να βρούμε τη σελίδα που ψάχνετε. Μπορεί να έχει αφαιρεθεί, να έχει αλλάξει το όνομά της ή να μην είναι προσωρινά διαθέσιμη.",
          )}
        </Typography>
        <Button
          variant="contained"
          color="primary"
          startIcon={<HomeIcon />}
          onClick={() => navigate({ to: userHomePath })}
        >
          {t("Μετάβαση στην Αρχική οθόνη")}
        </Button>
      </Box>
    </>
  );
}

export default NotFoundPage;
