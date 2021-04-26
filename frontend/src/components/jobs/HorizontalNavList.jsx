import React from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';

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
    marginLeft: '1px',
    color: 'rgba(0, 0, 0, 0.87)',
  },

}));

const HorizontalNavList = ({
  name,
  list,
  value,
  setValue,
}) => {
  const classes = useStyles();

  const handleListItemClick = (event, page) => {
    setValue(page);
  };

  return (
    <List
      aria-label={`${name}-nav`}
      className={classes.root}
    >
      {list !== undefined && list.map((li) => (
        <ListItem
          button
          onClick={(event) => handleListItemClick(event, li.name)}
          selected={value === li.name}
          key={li.name}
        >
          <ListItemText primary={li.name} primaryTypographyProps={{ noWrap: true }} />
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
};

export default HorizontalNavList;
