import {
    Box,
    Button,
    Dialog,
    DialogActions,
    DialogContent,
    DialogContentText,
    DialogTitle,
    TextField,
} from "@mui/material";
import {useTranslation} from "react-i18next";
import DeleteIcon from "@mui/icons-material/Delete";
import {useState} from "react";
import {enqueueSnackbar} from "notistack";
import {UseMutateFunction} from "@tanstack/react-query";
import {AxiosResponse} from "axios";

type DeleteModalProps = {
  open: boolean;
  setOpen: (open: boolean) => void;
  onConfirm: UseMutateFunction<
    AxiosResponse,
    Error,
    {
      id: number;
      changeReason: string;
    }
  >;
  title: string;
  description: string;
  id: number;
  isPending: boolean;
};

export const DeleteModal = (props: DeleteModalProps) => {
  const { open, setOpen, onConfirm, title, description, id, isPending } = props;
  const { t } = useTranslation();
  const [changeReason, setChangeReason] = useState<string>("");
  const handleConfirm = () => {
    if (!changeReason) {
      enqueueSnackbar(t("Παρακαλώ εισάγετε τον λόγο διαγραφής"), {
        variant: "error",
      });
      return;
    }
    onConfirm({ id, changeReason });
    setOpen(false);
  };

  return (
    <Dialog open={open} onClose={() => {}}>
      <DialogTitle>{title}</DialogTitle>
      <DialogContent>
        <DialogContentText>{description}</DialogContentText>
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: "1rem",
            width: "100%",
          }}
        >
          <TextField
            onChange={(e) => setChangeReason(e.target.value.trim())}
            label={t("Λόγος Διαγραφής")}
            fullWidth
            multiline={true}
            rows={5}
          />
        </Box>
      </DialogContent>
      <DialogActions>
        <Button
          variant={"contained"}
          onClick={() => setOpen(false)}
          color="primary"
        >
          {t("Ακύρωση")}
        </Button>
        <Button
          variant={"contained"}
          startIcon={<DeleteIcon />}
          onClick={handleConfirm}
          color="error"
          loading={isPending}
        >
          {t("Διαγραφή")}
        </Button>
      </DialogActions>
    </Dialog>
  );
};
