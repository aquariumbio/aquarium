import React from 'react';
import { makeStyles } from '@material-ui/core';
import Backdrop from '@material-ui/core/Backdrop';
import CircularProgress from '@material-ui/core/CircularProgress';
import PropTypes from 'prop-types';

const useStyles = makeStyles((theme) => ({
  backdrop: {
    zIndex: theme.zIndex.drawer + 1,
    color: '#fff',
  },
}));

const LoadingSpinner = ({ isLoading }) => {
  const classes = useStyles();

  return (
    <Backdrop
      className={classes.backdrop}
      open={isLoading}
      data-testid="loading"
      role="progressbar"
      aria-busy={isLoading}
    >
      <CircularProgress color="inherit" />
    </Backdrop>
  );
};

LoadingSpinner.propTypes = {
  isLoading: PropTypes.bool.isRequired,
};

export default LoadingSpinner;
