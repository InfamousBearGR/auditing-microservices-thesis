import { AnyRoute, createRoute } from "@tanstack/react-router";
import { Index } from "src/pages/company/features/index/Index";
import { View } from "src/pages/company/features/view/View";
import { Edit } from "src/pages/company/features/edit/Edit";
import { Add } from "src/pages/company/features/add/Add";
import { CompanyTabsLayout } from "src/pages/company/features/shared/CompanyTabsLayout";
import { View as CapitalView } from "src/pages/companyCapital/features/view/View";
import { Edit as CapitalEdit } from "src/pages/companyCapital/features/edit/Edit";
import { Index as MemberIndex } from "src/pages/member/features/index/Index";

export const createCompanyRoutes = (parentRoute: AnyRoute) => {
  const companyIndexRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/index",
    component: Index,
  });

  const companyAddRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/add",
    component: Add,
  });

  const companyEditRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/edit/$id",
    component: Edit,
  });

  // Layout route that hosts the tabs
  const companyTabsRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/$id",
    component: CompanyTabsLayout,
  });

  const companyDetailsRoute = createRoute({
    getParentRoute: () => companyTabsRoute,
    path: "/details",
    component: View,
  });

  const companyCapitalViewRoute = createRoute({
    getParentRoute: () => companyTabsRoute,
    path: "/capital/view",
    component: CapitalView,
  });

  const companyCapitalEditRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/$id/capital/edit",
    component: CapitalEdit,
  });

  const memberIndexRoute = createRoute({
    getParentRoute: () => companyTabsRoute,
    path: "/member/index",
    component: MemberIndex,
  });

  companyTabsRoute.addChildren([
    companyDetailsRoute,
    companyCapitalViewRoute,
    memberIndexRoute,
  ]);

  return [
    companyIndexRoute,
    companyAddRoute,
    companyEditRoute,
    companyTabsRoute,
    companyCapitalEditRoute,
  ];
};
