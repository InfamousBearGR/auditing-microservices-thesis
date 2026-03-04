import { createRoute, AnyRoute } from "@tanstack/react-router";
import { Index } from "src/pages/company/features/index/Index";
import { View } from "src/pages/company/features/view/View";

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

  return [companyIndexRoute, companyViewRoute];
};
