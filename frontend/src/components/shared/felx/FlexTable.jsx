import React from 'react';
import { element } from 'prop-types';
import { makeStyles } from '@material-ui/core';

const useStyles = makeStyles(() => ({
  flexWrapper: {
    padding: '0 16px',
  },
}));

const FlexTable = ({ children }) => {
  const classes = useStyles();

  return <div className={classes.flexWrapper}>{children}</div>;
};

FlexTable.propTypes = {
  children: element.isRequired,
};

export default FlexTable;
