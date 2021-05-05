import React, { useState, useEffect } from 'react';
import { useHistory } from 'react-router-dom';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Checkbox from '@material-ui/core/Checkbox';
import Toolbar from '@material-ui/core/Toolbar';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';

// import { makeStyles } from '@material-ui/core';
// import Typography from '@material-ui/core/Typography';
// import TextField from '@material-ui/core/TextField';
// import Divider from '@material-ui/core/Divider';
// import FormGroup from '@material-ui/core/FormGroup';
// import FormControlLabel from '@material-ui/core/FormControlLabel';
// import Switch from '@material-ui/core/Switch';

import usersAPI from '../../../helpers/api/users';
import permissionsAPI from '../../../helpers/api/permissions';
import { StandardButton, LinkButton } from '../../shared/Buttons';

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

  note: {
    color: 'rgba(0, 0, 0, 0.5)',
  },
}));

// eslint-disable-next-line no-unused-vars
const UserForm = ({ setIsLoading, setAlertProps, id }) => {
  const classes = useStyles();
  const history = useHistory();

  const [userName, setUserName] = useState('');
  const [userPermissions, setUserPermissions] = useState('');
  const [permissionsList, setPermissionsList] = useState({});
  const userId = window.localStorage.getItem('userId')
  const keyAdmin = Object.keys(permissionsList).find((key) => permissionsList[key] === 'admin');
  const keyRetired = Object.keys(permissionsList).find((key) => permissionsList[key] === 'retired');

  const init = async () => {
   // wrap the API call
    const response = await usersAPI.getProfile(id);
    if (!response) return;

    // success
    const user = response.user;
    setUserName(user.name);
    setUserPermissions(user.permission_ids);
  };

  useEffect(() => {
    const initOnce = async () => {
      // wrap the API call
      const responses = await permissionsAPI.getPermissions();
      if (!responses) return;

      // success
      setPermissionsList(responses.permissions);
    };

    init();
    initOnce();
  }, []);

  // toggle permission
  const togglePermission = async (status) => {
    userPermissions.indexOf(`.${status}.`) == -1
    ? setUserPermissions(`${userPermissions}${status}.`)
    : setUserPermissions(`${userPermissions}`.replace(`.${status}.`,'.'))
  }

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

    const response = await usersAPI.updatePermissions(formData, id);
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
    setAlertProps({
      message: 'Permissions updated',
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
            Permissions
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
          Permissions
        </Typography>

        {id == userId
          ? <Typography className={classes.note}>
              <i>Note: You cannot change your own admin or retired permission</i>
            </Typography>
          : ''
        }

        <Divider />

        <form id="user-form" name="user-form" data-cy="user-form" onSubmit={handleSubmit}>
          {// Add permissions checkboxes
           //   - Use ids for each checkbox instead of names
           //   - Build array of permission_ids on the fly when submit the form
          }
          <div>
            { Object.keys(permissionsList).map((key) => (
              <div>
                <FormControlLabel
                  disabled={id == userId && (key == keyAdmin || key == keyRetired)}
                  control={(
                    <Checkbox
                      id={`permission_id_${key}`}
                      color="primary"
                      checked={userPermissions.indexOf(`.${key}.`) != -1}
                      onChange={(event) => togglePermission(`${key}`)}
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

UserForm.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
  id: PropTypes.isRequired,
};

export default UserForm;
