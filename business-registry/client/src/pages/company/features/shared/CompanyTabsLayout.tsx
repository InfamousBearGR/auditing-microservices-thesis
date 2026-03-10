import {
  Outlet,
  useNavigate,
  useParams,
  useRouterState,
} from "@tanstack/react-router";
import { Box, Tab, Tabs } from "@mui/material";
import { useTranslation } from "react-i18next";
import { SyntheticEvent } from "react";

const TABS = [
  { labelKey: "Στοιχεία Επιχείρησης", pathSuffix: "details" },
  { labelKey: "Κεφάλαιο", pathSuffix: "capital/view" },
  { labelKey: "Εταίροι", pathSuffix: "member/index" },
];

export const CompanyTabsLayout = () => {
  const { t } = useTranslation();
  const { id } = useParams({ from: "/company/$id" });
  const navigate = useNavigate();
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  const activeTab = TABS.findIndex((tab) => pathname.endsWith(tab.pathSuffix));

  const handleTabChange = (_: SyntheticEvent, newValue: number) => {
    navigate({
      to: `/company/$id/${TABS[newValue].pathSuffix}`,
      params: { id },
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
      <Box sx={{ borderBottom: 1, borderColor: "divider" }}>
        <Tabs
          value={activeTab === -1 ? 0 : activeTab}
          onChange={handleTabChange}
        >
          {TABS.map((tab) => (
            <Tab key={tab.pathSuffix} label={t(tab.labelKey)} />
          ))}
        </Tabs>
      </Box>
      <Outlet />
    </Box>
  );
};
