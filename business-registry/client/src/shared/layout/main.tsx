import { AppBar, Box, Toolbar, Typography } from "@mui/material";
import { ReactNode } from "react";
import { Outlet } from "@tanstack/react-router";

const NAVY = "#0a1f44";
const NAVY_LIGHT = "#122b5e";

export const Main = (props: { children?: ReactNode }) => {
  const { children } = props;
  return (
    <Box
      sx={{
        display: "flex",
        flexDirection: "column",
        minHeight: "100vh",
        bgcolor: "#f0f2f5",
      }}
    >
      <AppBar
        position="sticky"
        elevation={2}
        sx={{
          bgcolor: NAVY,
          "& .MuiToolbar-root": { minHeight: 64 },
        }}
      >
        <Toolbar sx={{ gap: 2 }}>
          <Typography
            variant="h6"
            component="span"
            sx={{
              fontWeight: 700,
              letterSpacing: 1,
              color: "#ffffff",
              flexGrow: 1,
            }}
          >
            Business Registry
          </Typography>
          {children}
        </Toolbar>
      </AppBar>

      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          bgcolor: "#f0f2f5",
          borderTop: `3px solid ${NAVY_LIGHT}`,
        }}
      >
        <Outlet />
      </Box>
    </Box>
  );
};
