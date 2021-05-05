import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';

import { LinkButton } from '../../shared/Buttons';
import usersAPI from '../../../helpers/api/users';
import ShowMemerships from './ShowMemerships';

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
const Memberships = ({ setIsLoading, setAlertProps, id }) => {
  const classes = useStyles();

  const [userName, setUserName] = useState('');
  const [groups, setGroups] = useState('');

  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await usersAPI.getProfile(id);
      if (!response) return;

      // success
      const user = response.user;
      setUserName(user.name);

      // wrap the API call
      const responses = await usersAPI.getGroups(id);
      if (!responses) return;

      // success
      setGroups(responses.groups);
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
            {userName}
          </Typography>
          <Typography display="inline" variant="h6" component="h1">
            Memberships
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
          Memberships
        </Typography>

        <Divider />

        {groups
          /* eslint-disable-next-line max-len */
          ? <ShowMemerships groups={groups} setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
          : 'nothing here'}
      </div>
    </>
  );
};

Memberships.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
  id: PropTypes.isRequired,
};

export default Memberships;
