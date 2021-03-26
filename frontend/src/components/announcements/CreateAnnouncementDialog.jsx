import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import CloseIcon from '@material-ui/icons/Close';
import PropTypes from 'prop-types';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
  Grid,
  TextField,
  Divider,
  Button,
  Typography,
} from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  menuButton: {
    marginRight: theme.spacing(2),
    color: '#00ff22',
    fontSize: '1rem',
  },
  dialog: {
    width: '100%',
  },
  cancelButton: {
    marginLeft: 'auto',
  },
  confirmButton: {
    color: theme.palette.common.white,
    backgroundColor: '#065683',
    '&:hover': {
      backgroundColor: '#065683',
    },
    margin: theme.spacing(1),
  },
  closeIcon: {
    padding: theme.spacing(1),
    marginLeft: theme.spacing(30),
  },
  field: {
    marginTop: theme.spacing(3),
  },
}));

const CreateAnnouncementDialog = ({
  show,
  handleClose,
  handleCreateAnnouncement,
  handleTitle,
  handleMessage,
  handleActive,
}) => {
  const classes = useStyles();
  // const CustomTypography = withStyles(() => ({
  //     h3: {
  //         color: '#05486E',
  //     },
  // }))(Typography);

  return (
    <Dialog open={show} onClose={handleClose} className={classes.dialog}>
      <form onSubmit={handleCreateAnnouncement}>
        <DialogTitle className={classes.title}>
          <Grid container spacing={20}>
            <Grid item md={10} xs={12}>
              <Typography align="left" gutterBottom variant="h5">
                Create Announcement
              </Typography>
            </Grid>
            <Grid item md={2} xs={12}>
              <IconButton
                className={classes.closeIcon}
                onClick={handleClose}
                aria-label="close"
              >
                <CloseIcon />
              </IconButton>
            </Grid>
          </Grid>
        </DialogTitle>
        <DialogContent>
          <TextField
            required
            className={classes.field}
            fullWidth
            label="Title"
            name="Title"
            onChange={handleTitle}
            placeholder="Input title"
            variant="outlined"
          />
          <TextField
            required
            className={classes.field}
            fullWidth
            label="Message"
            name="Message"
            onChange={handleMessage}
            placeholder="Input message"
            variant="outlined"
          />
          <TextField
            required
            className={classes.field}
            fullWidth
            select
            SelectProps={{
              native: true,
            }}
            label="Active"
            onChange={handleActive}
            placeholder="Select state"
            variant="outlined"
          >
            <option value="true">True</option>
            <option value="false">False</option>
          </TextField>
        </DialogContent>
        <Divider />
        <DialogActions>
          <Button
            className={classes.cancelButton}
            onClick={handleClose}
            variant="contained"
          >
            Cancel
          </Button>
          <Button
            className={classes.confirmButton}
            type="submit"
            variant="contained"
          >
            Create
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};

CreateAnnouncementDialog.propTypes = {
  show: PropTypes.bool.isRequired,
  handleClose: PropTypes.func.isRequired,
  handleCreateAnnouncement: PropTypes.func.isRequired,
  handleTitle: PropTypes.func.isRequired,
  handleMessage: PropTypes.func.isRequired,
  handleActive: PropTypes.func.isRequired,
};

export default CreateAnnouncementDialog;
