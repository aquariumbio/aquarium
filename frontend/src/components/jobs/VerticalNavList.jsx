import React, { useState, useEffect, useReducer } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Collapse from '@material-ui/core/Collapse';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';

const useStyles = makeStyles(() => ({
  root: {
    minWidth: '170px',
    paddingTop: '0px',
    '& .Mui-selected': {
      background: 'rgba(64, 222, 253, 0.13)',
    },
    '& .MuiListItemIcon-root': {
      maxWidth: '45px',
    },
    '& .MuiListItem-gutters': {
      paddingRight: '0px',
    },
  },

  count: {
    fontSize: '0.625rem',
    marginLeft: '2px',
    color: 'rgba(0, 0, 0, 0.87)',
  },

  label: {
    opacity: '0.7',
    textTransform: 'uppercase',
    borderBottom: '1px #DDD solid',
    color: '#333',
    fontWeight: '300',
  },

  divider: {
    marginTop: '0',
  },
}));

// eslint-disable-next-line no-unused-vars
const VerticalNavList = ({
  name,
  list,
  value,
  setOperationType,
}) => {
  const classes = useStyles();

  const handleListItemClick = (event, page) => {
    setOperationType(page);
  };

  return (
    <List
      aria-label={`${name}-nav`}
      className={classes.root}
    >
      <Divider className={classes.divider} />

      {list !== undefined && list.map((li) => (
        <ListItem
          button
          onClick={(event) => handleListItemClick(event, li.name)}
          selected={value === li.name}
          key={li.name}
        >
          <Typography noWrap>{li.name} </Typography>
          <Typography className={classes.count}>({li.n})</Typography>
        </ListItem>
      ))}

    </List>
  );
};

VerticalNavList.propTypes = {
  name: PropTypes.string.isRequired,
  list: PropTypes.arrayOf(PropTypes.object).isRequired,
  value: PropTypes.string.isRequired,
  setOperationType: PropTypes.func.isRequired,
};

export default VerticalNavList;
