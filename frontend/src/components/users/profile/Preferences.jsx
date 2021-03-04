import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import FormGroup from '@material-ui/core/FormGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Switch from '@material-ui/core/Switch';

import { LinkButton, StandardButton } from '../../shared/Buttons';
import usersAPI from '../../../helpers/api/users';

const useStyles = makeStyles((theme) => ({
  root: {},

  container: {
    minWidth: 'lg',
    overflow: 'auto',
  },

  title: {
    fontSize: '2.5rem',
    fontWeight: '700',
    marginTop: theme.spacing(1),
    marginBottom: theme.spacing(0.25),
  },

  inputName: {
    fontSize: '1rem',
    fontWeight: '700',
  },

  spaceBelow: {
    marginBottom: theme.spacing(1),
  },

  show: {
    display: 'block',
  },

  hide: {
    display: 'none',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  wrapper: {
    padding: '0 24px',
  },
}));

const Preferences = ({ setIsLoading, setAlertProps, id }) => {
  const classes = useStyles();

  const [userName, setUserName] = useState('');
  const [labName, setLabName] = useState('');
  const [samplesPrivate, setSamplesPrivate] = useState(false);

  const toggleChecked = () => {
    setSamplesPrivate((prev) => !prev);
  };

  const init = async () => {
    // wrap the API call
    const response = await usersAPI.getProfile(id);
    if (!response) return;

    // success
    const user = response.user;
    setUserName(user.name);
    setLabName(user.lab_name ? user.lab_name : '');
    setSamplesPrivate(user.new_samples_private === '1' || user.new_samples_private === 'true');
  };

  useEffect(() => {
    init();
  }, []);

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();

    // set formData
    const form = document.querySelector('form');
    const data = new FormData(form);
    const formData = Object.fromEntries(data);

    // add new_samples_private to formData
    formData.new_samples_private = samplesPrivate;

    const response = await usersAPI.updatePreferences(formData, id);
    if (!response) return;

    // process errors
    const errors = response.errors;
    if (errors) {
      setAlertProps({
        message: JSON.stringify(errors, null, 2),
        severity: 'error',
        open: true,
      });
      return;
    }

    // success
    // pass alert popup in localStorage (does not work if pass as object, so pass as JSON string)
    localStorage.alert = JSON.stringify({
      message: id ? 'updated' : 'created',
      severity: 'success',
      open: true,
    });

    // reload page
    init();
  };

  return (
    <>
      <Toolbar className={classes.header}>
        <Breadcrumbs
          separator={<NavigateNextIcon fontSize="small" />}
          aria-label="breadcrumb"
          component="div"
          data-cy="page-title"
        >
          <Typography display="inline" variant="h6" component="h1">
            Users
          </Typography>
          <Typography display="inline" variant="h6" component="h1">
            {userName}
          </Typography>
          <Typography display="inline" variant="h6" component="h1">
            Preferences
          </Typography>
        </Breadcrumbs>

        <div>
          <LinkButton
            name="All"
            testName="all"
            text="All"
            type="button"
            linkTo="/users"
          />
        </div>
      </Toolbar>

      <Divider />

      <div className={classes.wrapper}>
        <form id="information-form" name="information-form" data-cy="information-form" onSubmit={handleSubmit}>
          <FormGroup>
            <FormControlLabel
              control={<Switch data-cy="privatetoggle" checked={samplesPrivate} onChange={toggleChecked} />}
              label="Make new samples private"
            />
          </FormGroup>

          <Typography variant="h4" className={classes.inputName} display="inline">
            Lab Name
          </Typography>

          <TextField
            name="lab_name"
            fullWidth
            value={labName}
            id="lab-name-input"
            onChange={(event) => setLabName(event.target.value)}
            variant="outlined"
            type="string"
            required
            inputProps={{
              'aria-label': 'lab-name-input',
              'data-cy': 'lab-name-input',
            }}
          />

          <Divider style={{ marginTop: '0px' }} />

          <StandardButton
            name="reset"
            testName="reset"
            handleClick={() => init()}
            text="Reset"
            light
          />

          <StandardButton
            name="save"
            testName="save"
            handleClick={handleSubmit}
            text="Save"
            type="submit"
            dark
          />
        </form>
      </div>
    </>
  );
};

Preferences.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  id: PropTypes.isRequired,
};

export default Preferences;
