import React, { useState, useEffect } from 'react';
import { useHistory, link } from 'react-router-dom';
import * as queryString from 'query-string';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Grid from '@material-ui/core/Grid';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import Button from '@material-ui/core/Button';

import ShowUsers from './ShowUsers';
import { LinkButton, StandardButton } from '../shared/Buttons';
import usersAPI from '../../helpers/api/users';
import permissionsAPI from '../../helpers/api/permissions';

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

  wrapper: {
    padding: '0 24px',
  },

  letter: {
    color: theme.palette.primary.main,
  },
}));

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

      <Divider />

      <div className={classes.wrapper}>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchAll()}>All</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('A')}>A</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('B')}>B</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('C')}>C</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('D')}>D</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('E')}>E</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('F')}>F</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('G')}>G</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('H')}>H</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('I')}>I</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('J')}>J</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('K')}>K</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('L')}>L</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('M')}>M</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('N')}>N</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('O')}>O</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('P')}>P</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('Q')}>Q</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('R')}>R</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('S')}>S</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('T')}>T</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('U')}>U</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('V')}>V</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('W')}>W</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('X')}>X</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('Y')}>Y</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('Z')}>Z</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('*')}>*</Button>
      </div>

      <Divider />

      {currentUsers
        /* eslint-disable-next-line max-len */
        ? <ShowUsers users={currentUsers} setIsLoading={setIsLoading} setAlertProps={setAlertProps} permissionsList={permissionsList} currentLetter={currentLetter} />
        : ''}
    </>
  );
};

UsersPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default UsersPage;
