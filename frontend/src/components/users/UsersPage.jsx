import React, { useState, useEffect } from 'react';
import { useHistory } from 'react-router-dom';
// eslint-disable-next-line import/no-extraneous-dependencies
import * as queryString from 'query-string';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import Button from '@material-ui/core/Button';

import ShowUsers from './ShowUsers';
import { LinkButton } from '../shared/Buttons';
import usersAPI from '../../helpers/api/users';
import permissionsAPI from '../../helpers/api/permissions';
import Alphabet from '../shared/Alphabet';

// Route: /object_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  space: {
    height: '24px',
  },
}));

// eslint-disable-next-line no-unused-vars
const UsersPage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const history = useHistory();

  // const [userLetters, setUserLetters] = useState([]);
  const [currentLetter, setCurrentLetter] = useState('');
  const [currentUsers, setCurrentUsers] = useState([]);
  const [permissionsList, setPermissionsList] = useState({});

  const fetchAll = async () => {
    // wrap the API call
    const response = await usersAPI.getUsers();
    if (!response) return;

    // success
    if (response.users) {
      setCurrentLetter('All');
      setCurrentUsers(response.users);
    }

    // screen does not refresh (we do not want it to) because only query parameters change
    // allows user to hit refresh to reload
    history.push('/users');
  };

  const fetchLetter = async (letter) => {
    // wrap the API call
    const response = await usersAPI.getUsersByLetter(letter);
    if (!response) return;

    // success
    if (response.users) {
      setCurrentLetter(letter.toUpperCase());
      setCurrentUsers(response.users);
    }

    // screen does not refresh (we do not want it to) because only query parameters change
    // allows user to hit refresh to reload
    history.push(`/users?letter=${letter}`.toLowerCase());
  };

  // initialize users and get permissions
  useEffect(() => {
    const init = async () => {
      const letter = queryString.parse(window.location.search).letter;

      if (letter) {
        // wrap the API calls
        const response = await permissionsAPI.getPermissions();
        if (!response) return;

        // success
        setPermissionsList(response.permissions);

        // wrap the API calls
        fetchLetter(letter);
      } else {
        // wrap the API calls
        const response = await permissionsAPI.getPermissions();
        if (!response) return;

        // success
        setPermissionsList(response.permissions);

        // wrap the API calls
        fetchAll();
      }
    };

    init();
  }, []);

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
            {currentLetter}
          </Typography>
        </Breadcrumbs>

        <div>
          <LinkButton
            name="New User"
            testName="new_user_btn"
            text="New User"
            dark
            type="button"
            linkTo="/users/new"
          />
        </div>
      </Toolbar>

      <Alphabet fetchLetter={fetchLetter} fetchAll={fetchAll} />

      {currentUsers
        /* eslint-disable-next-line max-len */
        ? <ShowUsers users={currentUsers} setIsLoading={setIsLoading} setAlertProps={setAlertProps} permissionsList={permissionsList} currentLetter={currentLetter} />
        : ''}
    </>
  );
};

UsersPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default UsersPage;