import { AnyRoute, createRoute } from "@tanstack/react-router";
import { Index } from "src/pages/legalEntity/features/index/Index";
import { View } from "src/pages/legalEntity/features/view/View";
import { Edit } from "src/pages/legalEntity/features/edit/Edit";
import { Add } from "src/pages/legalEntity/features/add/Add";

export const createLegalEntityRoutes = (parentRoute: AnyRoute) => {
  const legalEntityIndexRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/legalEntity/index",
    component: Index,
  });

  const legalEntityViewRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/legalEntity/view/$id",
    component: View,
  });

  const legalEntityEditRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/legalEntity/edit/$id",
    component: Edit,
  });

  const legalEntityAddRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/legalEntity/add",
    component: Add,
  });

  return [
    legalEntityIndexRoute,
    legalEntityViewRoute,
    legalEntityEditRoute,
    legalEntityAddRoute,
  ];
};
