import {SnackbarKey, SnackbarProvider} from "notistack";
import React from "react";
import {Close} from "@mui/icons-material";
import {IconButton} from "@mui/material";

const MySnackbarProvider = ({ children }: { children: any }) => {
  const notistackRef = React.createRef();
  const onClickDismiss = (key: SnackbarKey) => {
    // @ts-ignore
    notistackRef.current.closeSnackbar(key);
  };

  return (
    <SnackbarProvider
      // @ts-ignore
      ref={notistackRef}
      maxSnack={5}
      style={{ fontSize: "1.5rem" }}
      action={(key) => (
        <IconButton onClick={() => onClickDismiss(key)}>
          <Close sx={{ color: "white" }} />
        </IconButton>
      )}
    >
      {children}
    </SnackbarProvider>
  );
};

export default MySnackbarProvider;
