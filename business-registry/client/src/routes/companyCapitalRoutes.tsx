import { AnyRoute, createRoute } from "@tanstack/react-router";
import { View } from "src/pages/companyCapital/features/view/View";
import { Edit } from "src/pages/companyCapital/features/edit/Edit";

export const createCompanyCapitalRoutes = (parentRoute: AnyRoute) => {
  const companyCapitalViewRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/$id/capital/view",
    component: View,
  });

  const companyCapitalEditRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/$id/capital/edit",
    component: Edit,
  });

  return [companyCapitalViewRoute, companyCapitalEditRoute];
};
