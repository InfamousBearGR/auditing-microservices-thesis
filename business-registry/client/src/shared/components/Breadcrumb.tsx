import { Breadcrumbs, Typography } from "@mui/material";
import NavigateNextIcon from "@mui/icons-material/NavigateNext";
import { Link, useRouterState } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

interface BreadcrumbItem {
  labelKey: string;
  to?: string;
}

/**
 * Resolves the breadcrumb trail from a given pathname.
 * Supports dynamic segments like $id and $memberId.
 */
function resolveBreadcrumbs(pathname: string): BreadcrumbItem[] {
  const dashboardCrumb: BreadcrumbItem = {
    labelKey: "Κεντρικό Μενού",
    to: "/dashboard",
  };

  // /dashboard
  if (pathname === "/dashboard") {
    return [{ labelKey: "Κεντρικό Μενού" }];
  }

  // /company/index
  if (pathname === "/company/index") {
    return [dashboardCrumb, { labelKey: "Επιχειρήσεις" }];
  }

  // /company/add
  if (pathname === "/company/add") {
    return [
      dashboardCrumb,
      { labelKey: "Επιχειρήσεις", to: "/company/index" },
      { labelKey: "Εισαγωγή Επιχείρησης" },
    ];
  }

  // /company/:id/member/index
  const memberIndexMatch = pathname.match(
    /^\/company\/([^/]+)\/member\/index$/,
  );
  if (memberIndexMatch) {
    const id = memberIndexMatch[1];
    return [
      dashboardCrumb,
      { labelKey: "Επιχειρήσεις", to: "/company/index" },
      { labelKey: "Επιχείρηση", to: `/company/${id}/details` },
      { labelKey: "Εταίροι Επιχείρησης" },
    ];
  }

  // /company/:id/member/add
  const memberAddMatch = pathname.match(/^\/company\/([^/]+)\/member\/add$/);
  if (memberAddMatch) {
    const id = memberAddMatch[1];
    return [
      dashboardCrumb,
      { labelKey: "Επιχειρήσεις", to: "/company/index" },
      { labelKey: "Επιχείρηση", to: `/company/${id}/details` },
      { labelKey: "Εταίροι Επιχείρησης", to: `/company/${id}/member/index` },
      { labelKey: "Εισαγωγή Εταίρου" },
    ];
  }

  // /company/:id/member/view/:memberId
  const memberViewMatch = pathname.match(
    /^\/company\/([^/]+)\/member\/view\/([^/]+)$/,
  );
  if (memberViewMatch) {
    const id = memberViewMatch[1];
    return [
      dashboardCrumb,
      { labelKey: "Επιχειρήσεις", to: "/company/index" },
      { labelKey: "Επιχείρηση", to: `/company/${id}/details` },
      { labelKey: "Εταίροι Επιχείρησης", to: `/company/${id}/member/index` },
      { labelKey: "Προβολή Εταίρου" },
    ];
  }

  // /company/:id/member/edit/:memberId
  const memberEditMatch = pathname.match(
    /^\/company\/([^/]+)\/member\/edit\/([^/]+)$/,
  );
  if (memberEditMatch) {
    const id = memberEditMatch[1];
    return [
      dashboardCrumb,
      { labelKey: "Επιχειρήσεις", to: "/company/index" },
      { labelKey: "Επιχείρηση", to: `/company/${id}/details` },
      { labelKey: "Εταίροι Επιχείρησης", to: `/company/${id}/member/index` },
      { labelKey: "Επεξεργασία Εταίρου" },
    ];
  }

  // /company/:id/capital/view
  const capitalViewMatch = pathname.match(
    /^\/company\/([^/]+)\/capital\/view$/,
  );
  if (capitalViewMatch) {
    const id = capitalViewMatch[1];
    return [
      dashboardCrumb,
      { labelKey: "Επιχειρήσεις", to: "/company/index" },
      { labelKey: "Επιχείρηση", to: `/company/${id}/details` },
      { labelKey: "Κεφάλαιο και Μετοχές" },
    ];
  }

  // /company/:id/capital/edit
  const capitalEditMatch = pathname.match(
    /^\/company\/([^/]+)\/capital\/edit$/,
  );
  if (capitalEditMatch) {
    const id = capitalEditMatch[1];
    return [
      dashboardCrumb,
      { labelKey: "Επιχειρήσεις", to: "/company/index" },
      { labelKey: "Επιχείρηση", to: `/company/${id}/details` },
      { labelKey: "Κεφάλαιο και Μετοχές", to: `/company/${id}/capital/view` },
      { labelKey: "Επεξεργασία Κεφαλαίου" },
    ];
  }

  // /company/:id/details
  const companyDetailsMatch = pathname.match(/^\/company\/([^/]+)\/details$/);
  if (companyDetailsMatch) {
    return [
      dashboardCrumb,
      { labelKey: "Επιχειρήσεις", to: "/company/index" },
      { labelKey: "Προβολή Επιχείρησης" },
    ];
  }

  // /company/edit/:id
  const companyEditMatch = pathname.match(/^\/company\/edit\/([^/]+)$/);
  if (companyEditMatch) {
    return [
      dashboardCrumb,
      { labelKey: "Επιχειρήσεις", to: "/company/index" },
      { labelKey: "Επεξεργασία Επιχείρησης" },
    ];
  }

  // /person/index
  if (pathname === "/person/index") {
    return [dashboardCrumb, { labelKey: "Φυσικά Πρόσωπα" }];
  }

  // /person/add
  if (pathname === "/person/add") {
    return [
      dashboardCrumb,
      { labelKey: "Φυσικά Πρόσωπα", to: "/person/index" },
      { labelKey: "Εισαγωγή Φυσικού Προσώπου" },
    ];
  }

  // /person/view/:id
  const personViewMatch = pathname.match(/^\/person\/view\/([^/]+)$/);
  if (personViewMatch) {
    return [
      dashboardCrumb,
      { labelKey: "Φυσικά Πρόσωπα", to: "/person/index" },
      { labelKey: "Προβολή Φυσικού Προσώπου" },
    ];
  }

  // /person/edit/:id
  const personEditMatch = pathname.match(/^\/person\/edit\/([^/]+)$/);
  if (personEditMatch) {
    return [
      dashboardCrumb,
      { labelKey: "Φυσικά Πρόσωπα", to: "/person/index" },
      { labelKey: "Επεξεργασία Φυσικού Προσώπου" },
    ];
  }

  // /legalEntity/index
  if (pathname === "/legalEntity/index") {
    return [dashboardCrumb, { labelKey: "Νομικά Πρόσωπα" }];
  }

  // /legalEntity/add
  if (pathname === "/legalEntity/add") {
    return [
      dashboardCrumb,
      { labelKey: "Νομικά Πρόσωπα", to: "/legalEntity/index" },
      { labelKey: "Εισαγωγή Νομικού Προσώπου" },
    ];
  }

  // /legalEntity/view/:id
  const legalEntityViewMatch = pathname.match(/^\/legalEntity\/view\/([^/]+)$/);
  if (legalEntityViewMatch) {
    return [
      dashboardCrumb,
      { labelKey: "Νομικά Πρόσωπα", to: "/legalEntity/index" },
      { labelKey: "Προβολή Νομικού Προσώπου" },
    ];
  }

  // /legalEntity/edit/:id
  const legalEntityEditMatch = pathname.match(/^\/legalEntity\/edit\/([^/]+)$/);
  if (legalEntityEditMatch) {
    return [
      dashboardCrumb,
      { labelKey: "Νομικά Πρόσωπα", to: "/legalEntity/index" },
      { labelKey: "Επεξεργασία Νομικού Προσώπου" },
    ];
  }

  return [];
}

export const AppBreadcrumb = () => {
  const { t } = useTranslation();
  const pathname = useRouterState({
    select: (s) => s.location.pathname,
  });

  const crumbs = resolveBreadcrumbs(pathname);

  if (crumbs.length === 0) return null;

  return (
    <Breadcrumbs
      separator={
        <NavigateNextIcon
          fontSize="small"
          sx={{ color: "rgba(255,255,255,0.7)" }}
        />
      }
      aria-label="breadcrumb"
      sx={{ color: "rgba(255,255,255,0.85)" }}
    >
      {crumbs.map((crumb, index) => {
        const isLast = index === crumbs.length - 1;
        if (isLast || !crumb.to) {
          return (
            <Typography
              key={index}
              variant="body2"
              sx={{
                color: isLast ? "#ffffff" : "rgba(255,255,255,0.7)",
                fontWeight: isLast ? 600 : 400,
              }}
            >
              {t(crumb.labelKey)}
            </Typography>
          );
        }
        return (
          <Link
            key={index}
            to={crumb.to}
            style={{
              color: "rgba(255,255,255,0.7)",
              textDecoration: "none",
              fontSize: "0.875rem",
            }}
          >
            {t(crumb.labelKey)}
          </Link>
        );
      })}
    </Breadcrumbs>
  );
};
