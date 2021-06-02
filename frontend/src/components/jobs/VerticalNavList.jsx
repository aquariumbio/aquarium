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
  count: {
    marginLeft: '2px',
    color: 'rgba(0, 0, 0, 0.87)',
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

  return (
    <SideBar>
      <ListFixed ariaLabel={name}>
        {list.length < 1 && (
          <ListItem key="none">
            <Typography variant="body2">No Operations</Typography>
          </ListItem>
        )}

        {list !== undefined && list.map((li) => (
          <ListItem
            button
            onClick={(event) => handleListItemClick(event, li.name)}
            selected={value.name === li.name}
            key={li.name}
            // className={globalClasses.pointer}
          >
            <Typography variant="body2" noWrap>{li.name} </Typography>
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
