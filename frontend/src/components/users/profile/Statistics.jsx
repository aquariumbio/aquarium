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
import tokensAPI from '../../../helpers/api/tokens';

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

const Statistics = ({setIsLoading, setAlertProps, id}) => {
  const classes = useStyles();
  const [userName, setUserName] = useState('');

  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await usersAPI.getProfile(id);
      if (!response) return;

      // success
      const user = response['user']
      setUserName(user.name)
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
            Statistics
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
        <Typography>
          Statistics
        </Typography>
      </div>
    </>
  );
};

export default Statistics;
