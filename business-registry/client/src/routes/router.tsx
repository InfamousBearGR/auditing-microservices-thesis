import {
  createRootRoute,
  createRoute,
  createRouter,
  redirect,
  useNavigate,
} from "@tanstack/react-router";
import { useEffect } from "react";
import { Main } from "src/shared/layout/main";
import { WelcomePage } from "src/pages/welcome/features/welcomePage/WelcomePage";
import { Dashboard } from "src/pages/welcome/features/dashboard/Dashboard";
import { Error502 } from "src/pages/shared/errorPages/Error502";
import { NotFound } from "src/pages/shared/errorPages/NotFound";
import { createCompanyRoutes } from "src/routes/companyRoutes";
import { createPersonRoutes } from "src/routes/personRoutes";
import { createLegalEntityRoutes } from "src/routes/legalEntityRoutes";
import { createMemberRoutes } from "src/routes/memberRoutes";

const createAppRouter = () => {
  const rootRoute = createRootRoute({
    component: Main,
  });

  const loginRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/login",
    component: WelcomePage,
  });

  const indexRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/",
    beforeLoad: () => {
      throw redirect({ to: "/login" });
    },
  });

  const dashboardRoute = createRoute({
    getParentRoute: () => rootRoute,
    path: "/dashboard",
    component: Dashboard,
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

  const companyRoutes = createCompanyRoutes(rootRoute);
  const personRoutes = createPersonRoutes(rootRoute);
  const legalEntityRoutes = createLegalEntityRoutes(rootRoute);
  const memberRoutes = createMemberRoutes(rootRoute);

  const routeTree = rootRoute.addChildren([
    indexRoute,
    loginRoute,
    dashboardRoute,
    error502Route,
    notFoundRoute,
    ...companyRoutes,
    ...personRoutes,
    ...legalEntityRoutes,
    ...memberRoutes,
  ]);

  const NotFoundRedirect = () => {
    const navigate = useNavigate();
    useEffect(() => {
      navigate({ to: "/404" });
    }, []);
    return null;
  };

  return createRouter({
    routeTree,
    defaultNotFoundComponent: NotFoundRedirect,
  });
};

export const router = createAppRouter();
