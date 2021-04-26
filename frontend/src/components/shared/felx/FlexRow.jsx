import React from 'react';
import { element } from 'prop-types';

import { makeStyles } from '@material-ui/core';

const useStyles = makeStyles(() => ({
  flex: {
    display: '-ms-flexbox',
    // eslint-disable-next-line no-dupe-keys
    display: 'flex',
    position: 'relative',
  },

  flexRow: {
    padding: '8px 0',
    borderBottom: '1px solid #c0c0c0',
    '&:hover': {
      boxShadow: '0 0 3px 0 rgba(0, 0, 0, 0.8)',
    },
  },

  show: {
    display: 'block',
  },

  hide: {
    display: 'none',
  },

  pointer: {
    cursor: 'pointer',
  },
}));

/* Data Row */
const FlexRow = ({ children }) => {
  const classes = useStyles();

  return <div className={`${classes.flex} ${classes.flexRow}`}>{children}</div>;
};

FlexRow.propTypes = {
  children: element.isRequired,
};

export default FlexRow;
