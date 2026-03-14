import { RoleEnum } from "src/shared/enums/RoleEnum";
import {
  createContext,
  Dispatch,
  JSX,
  ReactNode,
  SetStateAction,
  useContext,
  useEffect,
  useState,
} from "react";
import { useCheckUserSession } from "src/shared/data-access/useCheckUserSession";

interface IUseAuth {
  authenticated: boolean;
  username: string;
  role: RoleEnum;
  userCantAccess: boolean;
  setUserCantAccess: Dispatch<SetStateAction<boolean>>;
  isLoading: boolean;
  userHomePath: string;
}

type AuthProviderProps = {
  children: ReactNode;
};

const AuthContext = createContext<IUseAuth | null>(null);

// eslint-disable-next-line react-refresh/only-export-components
export const useAuth = (): IUseAuth => {
  return useContext(AuthContext) as IUseAuth;
};

export const AuthProvider = ({ children }: AuthProviderProps): JSX.Element => {
  const { data, isLoading } = useCheckUserSession();
  const [userCantAccess, setUserCantAccess] = useState<boolean>(false);

  useEffect(() => {
    if (data?.data) {
      localStorage.setItem("userInfo", JSON.stringify(data?.data));
    }
  }, [data]);

  const contextValue = {
    authenticated: data?.data?.authenticated || false,
    username: data?.data?.username || "",
    role:
      data?.data?.role == 1
        ? RoleEnum.ADMIN
        : data?.data?.role == 2
          ? RoleEnum.USER
          : RoleEnum.NONE,
    userCantAccess,
    setUserCantAccess,
    isLoading,
    userHomePath: data?.data?.authenticated ? "/dashboard" : "/login",
  };

  return (
    <AuthContext.Provider value={contextValue}>{children}</AuthContext.Provider>
  );
};
