import { createRoute, AnyRoute } from "@tanstack/react-router";
import { Index } from "src/pages/company/features/index/Index";
import { View } from "src/pages/company/features/view/View";
import { Edit } from "src/pages/company/features/edit/Edit";
import { Add } from "src/pages/company/features/add/Add";

export const createCompanyRoutes = (parentRoute: AnyRoute) => {
  const companyIndexRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/index",
    component: Index,
  });

  const companyViewRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/view/$id",
    component: View,
  });

  const companyEditRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/edit/$id",
    component: Edit,
  });

  const companyAddRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/add",
    component: Add,
  });

  return [
    companyIndexRoute,
    companyViewRoute,
    companyEditRoute,
    companyAddRoute,
  ];
};
