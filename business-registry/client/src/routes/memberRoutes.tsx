import { AnyRoute, createRoute } from "@tanstack/react-router";
import { Index } from "src/pages/member/features/index/Index";
import { Add } from "src/pages/member/features/add/Add";
import { Edit } from "src/pages/member/features/edit/Edit";
import { View } from "src/pages/member/features/view/View";

export const createMemberRoutes = (parentRoute: AnyRoute) => {
  const memberIndexRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/$id/member/index",
    component: Index,
  });

  const memberViewRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/$id/member/view/$memberId",
    component: View,
  });

  const memberAddRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/$id/member/add",
    component: Add,
  });

  const memberEditRoute = createRoute({
    getParentRoute: () => parentRoute,
    path: "/company/$id/member/edit/$memberId",
    component: Edit,
  });

  return [memberIndexRoute, memberViewRoute, memberAddRoute, memberEditRoute];
};
