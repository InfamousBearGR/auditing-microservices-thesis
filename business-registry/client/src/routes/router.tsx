import {
  createRootRoute,
  createRoute,
  createRouter,
} from "@tanstack/react-router";
import { Main } from "src/shared/layout/main";
import { WelcomePage } from "src/pages/welcome/features/welcome/WelcomePage";

export const router = () => {
  const rootRoute = createRootRoute({
    component: Main,
  });

  const loginRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/login",
    component: WelcomePage,
  });

  const routeTree = rootRoute.addChildren([loginRoute]);

  return createRouter({ routeTree });
};
