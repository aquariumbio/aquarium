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

const LoadingBackdrop = ({ isLoading }) => {
  const classes = useStyles();

  return (
    <Backdrop className={classes.backdrop} open={isLoading} data-cy="ladoing-backdrop">
      <CircularProgress color="inherit" />
    </Backdrop>
  );
};

export default LoadingBackdrop;

LoadingBackdrop.propTypes = {
  isLoading: PropTypes.bool.isRequired,
};
