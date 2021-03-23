/* eslint-disable react/jsx-props-no-spreading */
import React, { useState } from 'react';
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

const useStyles = makeStyles(() => ({
  root: {
    width: '120px',
    '& .Mui-selected': {
      background: 'rgba(64, 222, 253, 0.13)',
    },
    '& body2': {
      fontSize: '10px',
      marginLeft: '1px',
      color: 'rgba(0, 0, 0, 0.87)',
    },
    '& .MuiListItemIcon-root': {
      maxWidth: '45px',
    },
    '& .MuiListItem-gutters': {
      paddingRight: '0px',
    },
  },

  label: {
    opacity: '0.7',
    textTransform: 'uppercase',
    borderBottom: '1px #DDD solid',
    color: '#333',
    fontWeight: '300',
  },
}));

// eslint-disable-next-line no-unused-vars
const SideBar = ({
  jobCounts,
  activeCounts,
  inactive,
  value,
  setValue,
  setOperationType,
}) => {
  const classes = useStyles();

  const [open, setOpen] = useState(false);

  const handleListItemClick = (event, page) => {
    setValue(page);
  };

  const handleOpen = () => {
    setOpen(!open);
  };

  return (
    <List
      id="jobs-vertical-nav"
      component="nav"
      aria-labelledby="jobs-page-navigation"
      className={classes.root}
    >
      <ListItem>
        <ListItemText primary="Jobs" className={classes.label} />
      </ListItem>

      <ListItem
        button
        onClick={(event) => handleListItemClick(event, 'unassigned')}
        selected={value === 'unassigned'}
        id="unassigned"
      >
        <Typography component="body1" noWrap>Unassigned</Typography>
        <Typography component="body2" className={classes.count}>{`(${jobCounts.unassigned})`}</Typography>
      </ListItem>

      <ListItem
        button
        onClick={(event) => handleListItemClick(event, 'assigned')}
        selected={value === 'assigned'}
        id="assigned"
      >
        <Typography component="body1" noWrap>Assigned</Typography>
        <Typography component="body2" className={classes.count}>{`(${jobCounts.assigned})`}</Typography>
      </ListItem>

      <ListItem
        button
        onClick={(event) => handleListItemClick(event, 'finished')}
        selected={value === 'finished'}
        id="finished"
      >
        <Typography component="body1" noWrap>Finished</Typography>
        <Typography component="body2" className={classes.count}>{`(${jobCounts.finished})`}</Typography>
      </ListItem>

      <ListItem>
        <ListItemText primary="Operations" className={classes.label} />
      </ListItem>

      {Object.keys(activeCounts).map((key, index) => (
        <ListItem
          button
          onClick={(event) => handleListItemClick(event, index + 3)}
          selected={value === index + 3}
          id="operations-list"
        >
          <Typography component="body1" noWrap>{key}</Typography>
          <Typography component="body2" className={classes.count}>{`(${activeCounts[`${key}`]})`}</Typography>
        </ListItem>
      ))}

      <ListItem button onClick={handleOpen} id="inactive">
        <ListItemIcon>
          {open ? <ExpandLess /> : <ExpandMore />}
        </ListItemIcon>
        <Typography component="body1" noWrap>Inactive</Typography>
      </ListItem>

      <Collapse in={open} timeout="auto" unmountOnExit>
        <List component="div" disablePadding className={classes.list} id="inactive-list">
          {inactive.map((key, count, index) => (
            <ListItem
              button
              className={classes.nested}
              onClick={(event) => handleListItemClick(event, index + 3 + activeCounts.length)}
              selected={value === index + 3 + activeCounts.length}
            >
              <Typography component="body1" noWrap>{key}</Typography>
              <Typography component="body2" className={classes.count}>{count}</Typography>
            </ListItem>
          ))}
        </List>
      </Collapse>
    </List>
  );
};

SideBar.propTypes = {
  jobCounts: PropTypes.isRequired,
  activeCounts: PropTypes.isRequired,
  inactive: PropTypes.isRequired,
  value: PropTypes.isRequired,
  setValue: PropTypes.isRequired,
  setOperationType: PropTypes.isRequired,
};

export default SideBar;
