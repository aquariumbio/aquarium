/* eslint-disable react/no-array-index-key */
import React, { useState, useEffect } from 'react';

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
    padding: "0 24px",
  },
}));

const Password = ({setIsLoading, setAlertProps, id}) => {
  const classes = useStyles();

  const [userName, setUserName] = useState('');
  const [password, setPassword] = useState('');
  const [password2, setPassword2] = useState('');

  const init = async () => {
    // wrap the API call
    const response = await usersAPI.getProfile(id);
    if (!response) return;

    // success
    const user = response['user']
    setUserName(user.name)
    setPassword(user.name)
    setPassword2(user.email)
  };

  useEffect(() => {
    init();
  }, []);

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();
    // set formData
    const form = document.querySelector('form'); // var
    const data = new FormData(form); // var
    const formData = Object.fromEntries(data)

    alert('TODO')
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
            Password
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
          <Typography variant="h4" className={classes.inputName} display="inline">
            New Password
          </Typography>
          <Typography variant="overline" color="error">
            {' * '}
          </Typography>

          <TextField
            name="password"
            fullWidth
            value=""
            id="password-input"
            onChange={(event) => setPassword(event.target.value)}
            variant="outlined"
            autoFocus
            required
            type="string"
            inputProps={{
              'aria-label': 'password-input',
              'data-cy': 'password-input',
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
            value=""
            id="password2-input"
            onChange={(event) => setPassword2(event.target.value)}
            variant="outlined"
            type="string"
            required
            inputProps={{
              'aria-label': 'password2-input',
              'data-cy': 'password2-input',
            }}
          />

          <Divider style={{ marginTop: '0px' }} />

          <StandardButton
            name="save"
            testName="save-group"
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

export default Password;
