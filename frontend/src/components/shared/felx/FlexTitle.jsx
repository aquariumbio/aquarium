import React from 'react';
import { arrayOf, element } from 'prop-types';
import { makeStyles } from '@material-ui/core';

const useStyles = makeStyles(() => ({
  flex: {
    display: '-ms-flexbox',
    // eslint-disable-next-line no-dupe-keys
    display: 'flex',
    position: 'relative',
  },

  /* Title row */
  flexTitle: {
    padding: '8px 0',
    borderBottom: '1px solid #c0c0c0',
  },
}));

// Title row
const FlexTitle = ({ children }) => {
  const classes = useStyles();

  return (
    <div className={`${classes.flex} ${classes.flexTitle}`}>{children}</div>
  );
};

FlexTitle.propTypes = {
  children: arrayOf(element).isRequired,
};

export default FlexTitle;
