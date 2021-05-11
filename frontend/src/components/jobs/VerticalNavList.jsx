import React from 'react';
import {
  string, arrayOf, shape, func, object,
} from 'prop-types';
import { makeStyles } from '@material-ui/core';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
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
  getOperations,
}) => {
  const classes = useStyles();

  const handleListItemClick = (page) => {
    getOperations(page);
  };

  if (list.length < 1) {
    return <Typography>No Operations</Typography>;
  }
  return (
    <List
      aria-label={`${name}-tablist`}
      className={classes.root}
      role="tablist"
    >
      <Divider className={classes.divider} />

      {list !== undefined && list.map((li) => (
        <ListItem
          button
          role="tab"
          onClick={(event) => handleListItemClick(event, li.name)}
          selected={value.name === li.name}
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
  name: string.isRequired,
  list: arrayOf(shape({ name: string })).isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  value: object.isRequired,
  getOperations: func.isRequired,
};

export default VerticalNavList;
