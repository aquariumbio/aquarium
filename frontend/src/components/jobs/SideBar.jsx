import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Collapse from '@material-ui/core/Collapse';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import ListSubheader from '@material-ui/core/ListSubheader';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import Typography from '@material-ui/core/Typography';

const useStyles = makeStyles((theme) => ({
  container: {
    minWidth: '120px',
    marginTop: '75px',
    overflow: 'hidden',
    display: 'flex',
    flexDirection: 'column',
    paddingBottom: '25px',
  },

  root: {
    backgroundColor: theme.palette.background.paper,
    position: 'relative',
    color: 'rgba(0, 0, 0, 0.87)',

    '& .Mui-selected': {
      background: 'rgba(64, 222, 253, 0.13)',
    },
    '& .MuiListItemIcon-root': {
      maxWidth: '45px',
    },
  },

  joblist: {
    overflow: 'visible',
  },

  categoryList: {
    flexGrow: 1,
    overflow: 'overlay',
    marginTop: theme.spacing(3),
  },

  count: {
    marginLeft: '2px',
  },

  label: {
    borderBottom: '1px #DDD solid',
    color: '#333333',
    display: 'flex',
  },
}));

const SideBar = ({
  jobCounts,
  activeCounts,
  inactive,
  value,
  setValue,
  category,
  setCategory,
}) => {
  const classes = useStyles();

  const [expand, setExpand] = useState(false);

  const handleJobStateClick = (event, jobState) => {
    setValue(jobState);
    setCategory('');
  };

  const handleOperationClick = (event, catName) => {
    setValue('categories');
    setCategory(catName);
  };

  const handleExpand = () => {
    setExpand(!expand);
  };

  return (
    <div className={classes.container}>
      <List
        role="tablist"
        aria-label="job-states"
        data-cy="job-states-tablist"
        className={`${classes.root} ${classes.joblist}`}
      >
        <ListSubheader key="categories" className={classes.label}>
          <ListItemText primary="JOBS" />
        </ListSubheader>

        <ListItem
          role="tab"
          onClick={(event) => handleJobStateClick(event, 'unassigned')}
          selected={value === 'unassigned'}
          id="unassigned"
          key="unassigned"
        >
          <Typography variant="body1" noWrap>Unassigned</Typography>
          <Typography variant="body2" className={classes.count}>{`(${jobCounts.unassigned})`}</Typography>
        </ListItem>

        <ListItem
          role="tab"
          onClick={(event) => handleJobStateClick(event, 'assigned')}
          selected={value === 'assigned'}
          id="assigned"
          key="assigned"
        >
          <Typography variant="body1" noWrap>Assigned</Typography>
          <Typography variant="body2" className={classes.count}>{`(${jobCounts.assigned})`}</Typography>
        </ListItem>

        <ListItem
          role="tab"
          onClick={(event) => handleJobStateClick(event, 'finished')}
          selected={value === 'finished'}
          id="finished"
          key="finished"
        >
          <Typography variant="body1" noWrap>Finished</Typography>
          <Typography variant="body2" className={classes.count}>{`(${jobCounts.finished})`}</Typography>
        </ListItem>
      </List>

      <List
        role="tablist"
        aria-label="categories"
        className={`${classes.root} ${classes.categoryList}`}
        subheader={<li />}
        disablePadding
      >
        <ListSubheader key="categories" className={classes.label}>
          <ListItemText primary="OPERATIONS" />
        </ListSubheader>

        {Object.keys(activeCounts).map((key) => (
          <ListItem
            role="tab"
            onClick={(event) => handleOperationClick(event, key)}
            selected={category === key}
            id="category-list"
            key={key}
          >
            <Typography variant="body1" noWrap>{key}</Typography>
            <Typography variant="body2" className={classes.count}>{`(${activeCounts[`${key}`]})`}</Typography>
          </ListItem>
        ))}

        <ListSubheader variant="button" role="button" disableGutters className={classes.label} onClick={handleExpand} id="inactive" key="inactive">
          <ListItemIcon>{expand ? <ExpandLess /> : <ExpandMore />}</ListItemIcon>
          <ListItemText primary="Inactive" />
        </ListSubheader>

        <Collapse in={expand} timeout="auto" unmountOnExit>
          {/* <List disableGutters disablePadding className={classes.list} id="inactive-list"> */}
          {inactive.map((key, count) => (
            <ListItem
              role="tab"
              button
              className={classes.nested}
              key={key}
              onClick={(event) => handleJobStateClick(event)}
              selected={value === key}
            >
              <Typography variant="body1" noWrap>{key}</Typography>
              <Typography variant="body2" className={classes.count}>{count}</Typography>
            </ListItem>
          ))}
          {/* </List> */}
        </Collapse>
      </List>
    </div>
  );
};

SideBar.propTypes = {
  jobCounts: PropTypes.shape({
    assigned: PropTypes.number,
    unassigned: PropTypes.number,
    finished: PropTypes.number,
  }).isRequired,
  activeCounts: PropTypes.objectOf(PropTypes.number).isRequired,
  inactive: PropTypes.arrayOf(PropTypes.string).isRequired,
  value: PropTypes.string.isRequired,
  setValue: PropTypes.func.isRequired,
  category: PropTypes.string.isRequired,
  setCategory: PropTypes.func.isRequired,
};

export default SideBar;
