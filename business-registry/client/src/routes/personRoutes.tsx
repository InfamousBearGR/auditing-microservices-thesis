import { AnyRoute, createRoute } from "@tanstack/react-router";
import { Index } from "src/pages/person/features/index/Index";
import { View } from "src/pages/person/features/view/View";
import { Edit } from "src/pages/person/features/edit/Edit";
import { Add } from "src/pages/person/features/add/Add";

export const createPersonRoutes = (parentRoute: AnyRoute) => {
  const personIndexRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/person/index",
    component: Index,
  });

  const personViewRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/person/view/$id",
    component: View,
  });

  const personEditRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/person/edit/$id",
    component: Edit,
  });

  const personAddRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/person/add",
    component: Add,
  });

  return [personIndexRoute, personViewRoute, personEditRoute, personAddRoute];
};
