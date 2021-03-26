import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import PropTypes from 'prop-types';
import {
  Box,
  TextField,
  Typography,
  Checkbox,
  FormControlLabel,
} from '@material-ui/core';
import CreateAnnouncementButton from './CreateAnnouncementButton';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100vh',
  },
  title: {
    fontWeight: 'bold',
    fontSize: '1.2rem',
  },
  form: {
    width: '100%',
    padding: theme.spacing(4),
  },
  closeIcon: {
    padding: theme.spacing(1),
    marginLeft: theme.spacing(30),
  },
  field: {
    marginTop: theme.spacing(3),
  },
  checkBoxGrid: {
    textAlign: 'center',
  },
}));

const CreateAnnouncementDialog = ({
  handleCreateAnnouncement,
  handleTitle,
  handleMessage,
  handleActive,
  active,
}) => {
  const classes = useStyles();

  return (
    <form className={classes.form} onSubmit={handleCreateAnnouncement}>
      <Box container direction="column">
        <Box>
          <Typography align="center" gutterBottom variant="h5" className={classes.title}>
            Create Announcement
          </Typography>
        </Box>
        <Box m={2}>
          <TextField
            required
            className={classes.field}
            fullWidth
            label="Title"
            name="Title"
            onChange={handleTitle}
            placeholder="Your announcement title"
            variant="outlined"
          />
        </Box>
        <Box m={2}>
          <TextField
            required
            className={classes.field}
            fullWidth
            label="Message"
            name="Message"
            onChange={handleMessage}
            placeholder="Your announcement message"
            variant="outlined"
            multiline
            rows={4}
            rowsMax={10}
          />
        </Box>
        <Box direction="row" m={2} className={classes.checkBoxGrid}>
          <FormControlLabel
            control={
              (
                <Checkbox
                  checked={active}
                  onChange={handleActive}
                  color="primary"
                  value="active"
                />
              )
            }
            label="Active"
            labelPlacement="start"
          />
        </Box>
        <Box>
          <CreateAnnouncementButton />
        </Box>
      </Box>
    </form>
  );
};

CreateAnnouncementDialog.propTypes = {
  handleCreateAnnouncement: PropTypes.func.isRequired,
  handleTitle: PropTypes.func.isRequired,
  handleMessage: PropTypes.func.isRequired,
  handleActive: PropTypes.func.isRequired,
  active: PropTypes.bool.isRequired,
};

export default CreateAnnouncementDialog;
