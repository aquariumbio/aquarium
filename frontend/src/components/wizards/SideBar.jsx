import React, { useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';

import tokensAPI from '../../helpers/api/tokensAPI';
// import wizardsAPI from '../../helpers/api/wizards';

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

// eslint-disable-next-line no-unused-vars
const SideBar = ({ setIsLoading, setAlertProps, wizardObject }) => {
  const classes = useStyles();

  // initialize to all and get permissions
  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await tokensAPI.isAuthenticated();
      if (!response) return;

      // success
    };

    init();
  }, []);

  return (
    <>
      <Grid
        item
        xs={3}
        name="side-bar"
        data-cy="side-bar"
        className={classes.root}
      >
        <div className={classes.wrapper}>
          Containers managed by {wizardObject.name}<br />
        </div>
      </Grid>
    </>
  );
};

SideBar.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  wizardObject: PropTypes.isRequired,
};

export default SideBar;
