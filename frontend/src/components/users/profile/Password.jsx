import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';

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

// eslint-disable-next-line no-unused-vars
const Password = ({ setIsLoading, setAlertProps, id }) => {
  const classes = useStyles();

  const [userName, setUserName] = useState('');
  const [password1, setPassword1] = useState('');
  const [password2, setPassword2] = useState('');

  const init = async () => {
    // wrap the API call
    const response = await usersAPI.getProfile(id);
    if (!response) return;

    // success
    const user = response.user;
    setUserName(user.name);
  };

  useEffect(() => {
    init();
  }, []);

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();

    // set formData
    const form = document.querySelector('#password-form');
    const data = new FormData(form);
    const formData = Object.fromEntries(data);

    const response = await usersAPI.updatePassword(formData, id);
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
    // put up popup
    setPassword1('');
    setPassword2('');
    setAlertProps({
      message: 'Password updated',
      severity: 'success',
      open: true,
    });
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
            Change Password
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
        <Typography variant="h4">
          Change Password
        </Typography>

        <Divider />

        <form id="password-form" name="password-form" data-cy="password-form" onSubmit={handleSubmit}>
          <Typography variant="h4" className={classes.inputName} display="inline">
            New Password
          </Typography>
          <Typography variant="overline" color="error">
            {' * '}
          </Typography>

          <TextField
            name="password1"
            fullWidth
            value={password1}
            id="password1-input"
            onChange={(event) => setPassword1(event.target.value)}
            variant="outlined"
            autoFocus
            required
            type="password"
            inputProps={{
              'aria-label': 'password1-input',
              'data-cy': 'password1-input',
            }}
            className={classes.spaceBelow}
          />

          <Typography variant="h4" className={classes.inputName} display="inline">
            Re-enter New Password
          </Typography>
          <Typography variant="overline" color="error">
            {' * '}
          </Typography>

          <TextField
            name="password2"
            fullWidth
            value={password2}
            id="password2-input"
            onChange={(event) => setPassword2(event.target.value)}
            variant="outlined"
            type="password"
            required
            inputProps={{
              'aria-label': 'password2-input',
              'data-cy': 'password2-input',
            }}
          />

          <Divider style={{ marginTop: '0px' }} />

          <StandardButton
            name="save"
            testName="save-password"
            handleClick={handleSubmit}
            text="Change Password"
            type="submit"
            dark
          />
        </form>
      </div>
    </>
  );
};

Password.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
  id: PropTypes.isRequired,
};

export default Password;
