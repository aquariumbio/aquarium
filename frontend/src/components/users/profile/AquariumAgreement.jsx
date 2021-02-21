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

const AquariumAgreement = ({ setIsLoading, setAlertProps, id }) => {
  const classes = useStyles();

  const [userName, setUserName] = useState('');
  const [aquariumAgreement, setAquariumAgreement] = useState('');

  const init = async () => {
    // wrap the API call
    const response = await usersAPI.getProfile(id);
    if (!response) return;

    // success
    const user = response.user;
    setUserName(user.name);
    setAquariumAgreement(user.aquarium_agreement === '1' || user.aquarium_agreement === 'true');
  };

  useEffect(() => {
    init();
  }, []);

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();
    const response = await usersAPI.updateAgreement('aquarium_agreement', id);
    if (!response) return;

    // success
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
            Aquarium Agreement
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
          Agreement
        </Typography>

        <Divider style={{ marginTop: '0px' }} />

        {aquariumAgreement ? (
          <Typography>
            ___ agreed on ___
          </Typography>
        ) : (
          <StandardButton
            name="agree"
            testName="agree"
            handleClick={handleSubmit}
            text="Agree"
            dark
          />
        )}
      </div>
    </>
  );
};

AquariumAgreement.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  id: PropTypes.isRequired,
};

export default AquariumAgreement;
