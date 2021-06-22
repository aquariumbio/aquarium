import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import Grid from '@material-ui/core/Grid';

import usersAPI from '../../helpers/api/usersAPI';
import groupsAPI from '../../helpers/api/groupsAPI';

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

// eslint-disable-next-line object-curly-newline, no-unused-vars
const SideBar = ({ setIsLoading, setAlertProps, id, refresh }) => {
  const classes = useStyles();
  const [users, setUsers] = useState([]);
  const newMember = '0';

  const handleSubmit = async (userId) => {
    // wrap the API call
    const response = await groupsAPI.addMember(id, userId);
    if (!response) return;

    // success
    // TODO: call setUsers
    refresh();
  };

  // initialize to all and get permissions
  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await usersAPI.getUsers();
      if (!response) return;

      // success
      setUsers(response.users);
    };

    init();
  }, []);

  return (
    <>
        <div className={classes.wrapper}>
          <TextField
            name="user_id"
            fullWidth
            id="user-id-input"
            value={newMember}
            onChange={(event) => handleSubmit(event.target.value)}
            variant="outlined"
            type="string"
            inputProps={{
              'aria-label': 'user-id-input',
              'data-cy': 'user-id-input',
            }}
            select
          >
            <MenuItem key="0" value="0">Add Member</MenuItem>
            {users.map((user) => (
              <MenuItem key={user.id} value={user.id}>{user.name}</MenuItem>
            ))}
          </TextField>
        </div>
    </>
  );
};

SideBar.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  id: PropTypes,
  refresh: PropTypes.func,
};

export default SideBar;
