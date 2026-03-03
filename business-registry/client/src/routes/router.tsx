import {
  createRootRoute,
  createRoute,
  createRouter,
} from "@tanstack/react-router";
import { Main } from "src/shared/layout/main";
import { WelcomePage } from "src/pages/welcome/features/WelcomePage/WelcomePage";
import { Error502 } from "src/pages/shared/errorPages/Error502";
import NotFound from "src/pages/shared/errorPages/NotFound";

export const router = () => {
  const rootRoute = createRootRoute({
    component: Main,
  });

  const loginRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/login",
    component: WelcomePage,
  });

  const error502Route = createRoute({
    getParentRoute: () => rootRoute,
    path: "/502",
    component: Error502,
  });

  const notFoundRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/404",
    component: NotFound,
  });

  const routeTree = rootRoute.addChildren([
    loginRoute,
    error502Route,
    notFoundRoute,
  ]);

  return createRouter({ routeTree });
};
