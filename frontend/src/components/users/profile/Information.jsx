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
import usersAPI from '../../../helpers/api/usersAPI';
import globalUseSyles from '../../../globalUseStyles';

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

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
}));

// eslint-disable-next-line no-unused-vars
const Information = ({ setIsLoading, setAlertProps, id }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();

  const [userName, setUserName] = useState('');
  const [userEmail, setUserEmail] = useState('');
  const [userPhone, setUserPhone] = useState('');

  const init = async () => {
    // wrap the API call
    const response = await usersAPI.getProfile(id);
    if (!response) return;

    // success
    const user = response.user;
    setUserName(user.name);
    setUserEmail(user.email ? user.email : '');
    setUserPhone(user.phone ? user.phone : '');
  };

  useEffect(() => {
    init();
  }, []);

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();

    // set formData
    const form = document.querySelector('#information-form');
    const data = new FormData(form);
    const formData = Object.fromEntries(data);

    const response = await usersAPI.updateInfo(formData, id);
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
            Information
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

      <div className={globalClasses.wrapper}>
        <Typography variant="h4">
          Information
        </Typography>

        <Divider />

        <form id="information-form" name="information-form" data-cy="information-form" onSubmit={handleSubmit}>
          <Typography variant="h4" className={classes.inputName} display="inline">
            Name
          </Typography>
          <Typography variant="overline" color="error">
            {' * '}
          </Typography>

          <TextField
            name="name"
            fullWidth
            value={userName}
            id="name-input"
            onChange={(event) => setUserName(event.target.value)}
            variant="outlined"
            autoFocus
            required
            type="string"
            inputProps={{
              'aria-label': 'name-input',
              'data-cy': 'name-input',
            }}
            className={classes.spaceBelow}
          />

          <Typography variant="h4" className={classes.inputName} display="inline">
            Email
          </Typography>
          <Typography variant="overline" color="error">
            {' * '}
          </Typography>

          <TextField
            name="email"
            fullWidth
            value={userEmail}
            id="email-input"
            onChange={(event) => setUserEmail(event.target.value)}
            variant="outlined"
            type="string"
            required
            inputProps={{
              'aria-label': 'email-input',
              'data-cy': 'email-input',
            }}
          />

          <Typography variant="h4" className={classes.inputName} display="inline">
            Phone
          </Typography>
          <Typography variant="overline" color="error">
            {' * '}
          </Typography>

          <TextField
            name="phone"
            fullWidth
            value={userPhone}
            id="phone-input"
            onChange={(event) => setUserPhone(event.target.value)}
            variant="outlined"
            type="string"
            required
            inputProps={{
              'aria-label': 'phone-input',
              'data-cy': 'phone-input',
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
            testName="save-info"
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

Information.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
  id: PropTypes.isRequired,
};

export default Information;
