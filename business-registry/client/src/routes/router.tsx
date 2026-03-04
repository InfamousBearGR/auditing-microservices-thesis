import {
  createRootRoute,
  createRoute,
  createRouter,
  redirect,
  useNavigate,
} from "@tanstack/react-router";
import { useEffect } from "react";
import { Main } from "src/shared/layout/main";
import { WelcomePage } from "src/pages/welcome/features/WelcomePage/WelcomePage";
import { Error502 } from "src/pages/shared/errorPages/Error502";
import { NotFound } from "src/pages/shared/errorPages/NotFound";
import { createCompanyRoutes } from "src/routes/companyRoutes";

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

  const routeTree = rootRoute.addChildren([
    indexRoute,
    loginRoute,
    error502Route,
    notFoundRoute,
    ...companyRoutes,
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
