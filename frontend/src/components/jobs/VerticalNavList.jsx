import React from 'react';
import {
  string, arrayOf, shape, func, object,
} from 'prop-types';
import { makeStyles } from '@material-ui/core';
import ListItem from '@material-ui/core/ListItem';
import Typography from '@material-ui/core/Typography';
import SideBar from '../shared/layout/SideBar';
import ListFixed from '../shared/layout/ListFixed';

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
}));

const VerticalNavList = ({
  name,
  list,
  value,
  getOperations,
}) => {
  const classes = useStyles();

  const handleListItemClick = (event, page) => {
    getOperations(page);
  };

  if (list.length < 1) {
    return <Typography>No Operations</Typography>;
  }
  return (
    <SideBar>
      <ListFixed ariaLabel={name}>
        {list !== undefined && list.map((li) => (
          <ListItem
            button
            role="tab"
            onClick={(event) => handleListItemClick(event, li.name)}
            selected={value.name === li.name}
            key={li.name}
            disableGutters
          >
            <Typography variant="body1" noWrap>{li.name} </Typography>
            <Typography variant="body2" className={classes.count}>({li.n})</Typography>
          </ListItem>
        ))}
      </ListFixed>
    </SideBar>

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
