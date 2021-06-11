import React from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import Typography from '@material-ui/core/Typography';

const useStyles = makeStyles((theme) => ({
  root: {
    display: 'inline-block',
    backgroundColor: theme.palette.background.paper,
    '& .MuiList-root': {
      display: 'inline-flex',
    },
    '& .Mui-selected': {
      borderBottom: '5px solid #6FC1FF',
      background: theme.palette.background.paper,
    },
    '& .MuiListItemIcon-root': {
      maxWidth: '45px',
    },
  },

  count: {
    fontSize: '0.625rem',
    marginLeft: '2px',
    color: 'rgba(0, 0, 0, 0.87)',
  },

}));

const HorizontalNavList = ({
  name,
  list,
  value,
  setValue,
  count,
}) => {
  const classes = useStyles();

  const handleListItemClick = (event, page) => {
    setValue(page);
  };

  return (
    <List
      aria-label={`${name}-tablist`}
      role="tablist"
      className={classes.root}
    >
      {list !== undefined && list.map((li) => (
        <ListItem
          button
          role="tab"
          onClick={(event) => handleListItemClick(event, li.name)}
          selected={value === li.name}
          key={li.name}
        >
          <Typography noWrap>{li.name}</Typography>
          {!!count && <Typography className={classes.count}>({count})</Typography>}
        </ListItem>
      ))}
    </List>
  );
};

HorizontalNavList.propTypes = {
  name: PropTypes.string.isRequired,
  list: PropTypes.arrayOf(PropTypes.object).isRequired,
  value: PropTypes.string.isRequired,
  setValue: PropTypes.func.isRequired,
  count: PropTypes.number.isRequired,
};

export default HorizontalNavList;
