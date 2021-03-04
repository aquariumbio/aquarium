import React, { useState, useEffect, useRef } from 'react';
import { useHistory } from 'react-router-dom';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import MenuItem from '@material-ui/core/MenuItem';
import TextareaAutosize from '@material-ui/core/TextareaAutosize';
import Grid from '@material-ui/core/Grid';
import Alert from '@material-ui/lab/Alert';
import Divider from '@material-ui/core/Divider';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Checkbox from '@material-ui/core/Checkbox';

import objectsAPI from '../../helpers/api/objects';
import usersAPI from '../../helpers/api/users';
import permissionsAPI from '../../helpers/api/permissions';
import tokensAPI from '../../helpers/api/tokens';
import LoadingSpinner from '../shared/LoadingSpinner';
import { StandardButton, LinkButton } from '../shared/Buttons';
import utils from '../../helpers/utils';
import AlertToast from '../shared/AlertToast';

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
}));

const UserForm = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const history = useHistory();

  const [disableSubmit, setDisableSubmit] = useState(false);

  const [userName, setUserName] = useState('');
  const [userLogin, setUserLogin] = useState('');
  const [userPassword, setUserPassword] = useState('');
  const [permissionsList, setPermissionsList] = useState({});

  useEffect(() => {
    const initNew = async () => {
      // wrap the API call
      const response = await permissionsAPI.getPermissions();
      if (!response) return;

      // success
      setPermissionsList(response.permissions);
    };

    initNew();
  }, []);

  // Update allowSubmit state
  useEffect(() => {
    setDisableSubmit(
      !userName.trim() ||
      !userLogin.trim() ||
      !userPassword
    );
  });

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();

    // set formData
    const form = document.querySelector('form');
    const data = new FormData(form);
    const formData = Object.fromEntries(data);

    // add permission_ids to formData
    // eslint-disable-next-line camelcase
    const permission_ids = [];
    Object.keys(permissionsList).forEach((key) => {
      if (document.getElementById(`permission_id_${key}`).checked) permission_ids.push(key);
    });
    // eslint-disable-next-line camelcase
    formData.permission_ids = permission_ids;

    const response = await usersAPI.create(formData);
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
    // pass alert popup in sessionStorage (does not work if pass as object, so pass as JSON string)
    sessionStorage.alert = JSON.stringify({
      message: response.message,
      severity: 'success',
      open: true,
    });

    history.push('/users');
  };

  return (
    <Container className={classes.root} maxWidth="xl" data-cy="user-container">
      <Typography variant="h1" align="center" className={classes.title}>
        New User
      </Typography>
      <Typography align="right">* field is required</Typography>

      <form id="user-form" name="user-form" data-cy="user-form" onSubmit={handleSubmit}>
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
          id="user-name-input"
          onChange={(event) => setUserName(event.target.value)}
          variant="outlined"
          autoFocus
          required
          type="string"
          inputProps={{
            'aria-label': 'user-name-input',
            'data-cy': 'user-name-input',
          }}
          className={classes.spaceBelow}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Login
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="login"
          fullWidth
          value={userLogin}
          id="user-login-input"
          onChange={(event) => setUserLogin(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'user-login-input',
            'data-cy': 'user-login-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Password
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="password"
          fullWidth
          value={userPassword}
          id="user-password-input"
          onChange={(event) => setUserPassword(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'user-password-input',
            'data-cy': 'user-password-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName}>
          Permissions
        </Typography>

        {// Add permissions checkboxes
         //   - Use ids for each checkbox instead of names
         //   - Build array of permission_ids on the fly when submit the form
         //   - Hide checkbox for 'retired' */
         //     eslint-disable-next-line max-len
         //   - Could also chain .filter(ey => permissionsList[key]!='retired').map(key => ...) but that loops twice
        }
        <div>
          { Object.keys(permissionsList).map((key) => (
            <div className={permissionsList[key] === 'retired' ? classes.hide : classes.show}>
              <FormControlLabel
                control={(
                  <Checkbox
                    id={`permission_id_${key}`}
                    color="primary"
                    inputProps={{
                      'aria-label': 'permission-id',
                      'data-cy': 'permission-id-checkbox',
                    }}
                  />
                )}
                label={permissionsList[key]}
              />
            </div>
          ))}
        </div>

        <Divider style={{ marginTop: '0px' }} />

        <LinkButton
          name="back"
          testName="back"
          text="Cancel"
          linkTo="/users"
        />

        <StandardButton
          name="save"
          testName="save-user"
          handleClick={handleSubmit}
          text="Save"
          type="submit"
          disabled={disableSubmit}
          dark
        />
      </form>
    </Container>
  );
};

UserForm.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default UserForm;
