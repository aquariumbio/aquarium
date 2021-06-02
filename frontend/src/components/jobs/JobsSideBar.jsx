import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Collapse from '@material-ui/core/Collapse';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import Typography from '@material-ui/core/Typography';
import SideBar from '../shared/layout/SideBar';
import ListFixed from '../shared/layout/ListFixed';
import ListScroll from '../shared/layout/ListScroll';

const useStyles = makeStyles(() => ({
  count: {
    marginLeft: '2px',
    color: 'rgba(0, 0, 0, 0.87)',
  },

  label: {
    borderBottom: '1px #DDD solid',
    color: '#333333',
    display: 'flex',
  },
  inactive: {
    color: 'rgba(0, 0, 0, 0.54)',
  },
}));

const JobsSideBar = ({
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

  const opsList = Object.keys(activeCounts).map((key) => (
    <ListItem
      button
      role="tab"
      onClick={(event) => handleOperationClick(event, key)}
      selected={category === key}
      id="category-list"
      key={key}
    >
      <Typography variant="caption" noWrap>{key}</Typography>
      <Typography variant="caption" className={classes.count}>{`(${activeCounts[`${key}`]})`}</Typography>
    </ListItem>
  ));

  opsList.push(
    <ListItem button className={classes.label} onClick={handleExpand} id="inactive" key="inactive">
      <ListItemIcon>{expand ? <ExpandLess /> : <ExpandMore />}</ListItemIcon>
      <ListItemText primary="Inactive" />
    </ListItem>,
    <Collapse in={expand} timeout="auto" unmountOnExit key="collapse">
      {inactive.map((key, count) => (
        <ListItem
          button
          className={classes.inactive}
          key={key}
          onClick={(event) => handleJobStateClick(event)}
          selected={value === key}
        >
          <Typography variant="caption" noWrap>{key}</Typography>
          <Typography variant="caption" className={classes.count}>({count})</Typography>
        </ListItem>
      ))}
    </Collapse>,
  );

  return (
    <SideBar small>
      <ListFixed
        title="JOBS"
        ariaLabel="job-states"
      >
        <ListItem
          button
          role="tab"
          onClick={(event) => handleJobStateClick(event, 'unassigned')}
          selected={value === 'unassigned'}
          id="unassigned"
          key="unassigned"

        >
          <Typography variant="caption" noWrap>Unassigned</Typography>
          <Typography variant="caption" className={classes.count}>{`(${jobCounts.unassigned})`}</Typography>
        </ListItem>

        <ListItem
          button
          role="tab"
          onClick={(event) => handleJobStateClick(event, 'assigned')}
          selected={value === 'assigned'}
          id="assigned"
          key="assigned"

        >
          <Typography variant="caption" noWrap>Assigned</Typography>
          <Typography variant="caption" className={classes.count}>{`(${jobCounts.assigned})`}</Typography>
        </ListItem>

        <ListItem
          button
          role="tab"
          onClick={(event) => handleJobStateClick(event, 'finished')}
          selected={value === 'finished'}
          id="finished"
          key="finished"

        >
          <Typography variant="caption" noWrap>Finished</Typography>
          <Typography variant="caption" className={classes.count}>{`(${jobCounts.finished})`}</Typography>
        </ListItem>
      </ListFixed>

      <ListScroll
        title="OPERATIONS"
        ariaLabel="categories"
        spacingTop
      >

        {opsList}

      </ListScroll>
    </SideBar>
  );
};

JobsSideBar.propTypes = {
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

export default JobsSideBar;
