export type ErrorResponse = {
  message: string;
  status: number;
};

export type ParametricDto = {
  id: number;
  description: string;
};

export type UserSessionResponse = {
  authenticated: boolean;
  username: string;
  role: number;
};
