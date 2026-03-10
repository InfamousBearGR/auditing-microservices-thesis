import {
  AppBar,
  Box,
  IconButton,
  InputAdornment,
  Menu,
  MenuItem,
  Select,
  SelectChangeEvent,
  Toolbar,
  Typography,
} from "@mui/material";
import AccountCircle from "@mui/icons-material/AccountCircle";
import LanguageIcon from "@mui/icons-material/Language";
import { Logout } from "@mui/icons-material";
import { MouseEvent, ReactNode, useEffect, useState } from "react";
import { Link, Outlet, useNavigate } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { useAuth } from "src/shared/context/useAuth";
import { useLogout } from "src/shared/data-access/useLogout";
import { AppBreadcrumb } from "src/shared/components/Breadcrumb";

const NAVY = "#0a1f44";
const NAVY_LIGHT = "#122b5e";
const MENU_ID = "primary-search-account-menu";

const LANG_OPTIONS = [
  { value: "el", label: "Ελληνικά" },
  { value: "en", label: "English" },
];

interface ProfileMenuProps {
  anchorEl: HTMLElement | null;
  onClose: () => void;
  onLogout: () => void;
  logoutLabel: string;
}

const ProfileMenu = ({
  anchorEl,
  onClose,
  onLogout,
  logoutLabel,
}: ProfileMenuProps) => (
  <Menu
    anchorEl={anchorEl}
    anchorOrigin={{ vertical: "bottom", horizontal: "right" }}
    id={MENU_ID}
    keepMounted
    transformOrigin={{ vertical: "top", horizontal: "right" }}
    open={Boolean(anchorEl)}
    onClose={onClose}
  >
    <MenuItem
      onClick={onLogout}
      sx={{
        display: "flex",
        alignItems: "center",
        gap: ".5rem",
        color: "black",
      }}
    >
      <Logout sx={{ width: "1rem", height: "1rem" }} />
      <Typography variant="body2">{logoutLabel}</Typography>
    </MenuItem>
  </Menu>
);

export const Main = ({ children }: { children?: ReactNode }) => {
  const { t, i18n } = useTranslation();
  const [lang, setLang] = useState<string>(i18n.language ?? "el");
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const {
    userHomePath,
    userCantAccess,
    setUserCantAccess,
    authenticated,
    username,
  } = useAuth();
  const navigate = useNavigate();
  const { mutate: logout } = useLogout();

  useEffect(() => {
    if (userCantAccess) {
      navigate({ to: userHomePath });
      setUserCantAccess(false);
    }
  }, [navigate, setUserCantAccess, userCantAccess, userHomePath]);

  const handleLangChange = (e: SelectChangeEvent) => {
    const newLang = e.target.value;
    setLang(newLang);
    i18n.changeLanguage(newLang);
    localStorage.setItem("lng", newLang);
  };

  const handleProfileMenuOpen = (event: MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClose = () => setAnchorEl(null);

  const handleLogoutClick = () => {
    handleMenuClose();
    logout();
  };

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
        sx={{ bgcolor: NAVY, "& .MuiToolbar-root": { minHeight: 64 } }}
      >
        <Toolbar sx={{ gap: 2 }}>
          <Box
            sx={{
              fontWeight: 700,
              letterSpacing: 1,
              color: "#ffffff",
              flexGrow: 1,
            }}
          >
            <Link
              style={{ textDecoration: "none", color: "white" }}
              to={userHomePath}
            >
              <Typography variant="h5" noWrap>
                {t("Επιχειρηματικό Μητρώο")}
              </Typography>
            </Link>
          </Box>

          <AppBreadcrumb />

          {children}

          <Select
            value={lang}
            onChange={handleLangChange}
            size="small"
            startAdornment={
              <InputAdornment position="start">
                <LanguageIcon sx={{ color: "#ffffff", fontSize: 20 }} />
              </InputAdornment>
            }
            sx={{
              color: "#ffffff",
              "& .MuiOutlinedInput-notchedOutline": {
                borderColor: "rgba(255,255,255,0.5)",
              },
              "&:hover .MuiOutlinedInput-notchedOutline": {
                borderColor: "#ffffff",
              },
              "& .MuiSvgIcon-root": { color: "#ffffff" },
            }}
          >
            {LANG_OPTIONS.map(({ value, label }) => (
              <MenuItem key={value} value={value}>
                {label}
              </MenuItem>
            ))}
          </Select>

          {authenticated && (
            <IconButton
              sx={{
                display: "flex",
                borderRadius: "5px",
                gap: 1,
                alignItems: "center",
              }}
              aria-label="account of current user"
              aria-controls={MENU_ID}
              aria-haspopup="true"
              onClick={handleProfileMenuOpen}
              color="inherit"
            >
              <AccountCircle />
              <Typography
                sx={{
                  display: { xs: "none", md: "flex" },
                  alignItems: "center",
                }}
                variant="subtitle2"
              >
                {username}
              </Typography>
            </IconButton>
          )}
        </Toolbar>

        <ProfileMenu
          anchorEl={anchorEl}
          onClose={handleMenuClose}
          onLogout={handleLogoutClick}
          logoutLabel={t("Αποσύνδεση")}
        />
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
