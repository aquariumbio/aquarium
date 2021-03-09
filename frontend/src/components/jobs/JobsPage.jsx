import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Grid from '@material-ui/core/Grid';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';

import SideBar from './SideBar';
import ShowAssigned from './ShowAssigned';
import ShowUnassigned from './ShowUnassigned';
import ShowFinished from './ShowFinished';
import ShowByOperation from './ShowByOperation';
import jobsAPI from '../../helpers/api/jobs';

// Route: /job_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles(() => ({
  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
}));

// eslint-disable-next-line no-unused-vars
const JobsPage = ({ setIsLoading, setAlertProps }) => {
  const classes = useStyles();

  const [list, setList] = useState('Unassigned');
  const [operationType, setOperationType] = useState();
  const [jobCounts, setJobCounts] = useState({});
  const [activeCounts, setActiveCounts] = useState({});
  const [inactive, setInactive] = useState([]);

  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await jobsAPI.getCounts();
      if (!response) return;

      // success
      setJobCounts(response.counts.jobs);
      setActiveCounts(response.counts.operations.active);
      setInactive(response.counts.operations.inactive);
    };

    init();
  }, []);

  return (
    <>
      <Toolbar className={classes.header}>
        <Breadcrumbs
          separator={<NavigateNextIcon fontSize="small" />}
          aria-label="breadcrumb"
          component="div"
          data-cy="page-title"
        >
          <Typography display="inline" variant="h6" component="h1">
            Jobs
          </Typography>
          <Typography display="inline" variant="h6" component="h1">
            {list === 'Operation' ? operationType : list}
          </Typography>
        </Breadcrumbs>
      </Toolbar>

      <Divider />

      <Grid container className={classes.root}>
        {/* SIDE BAR */}
        <SideBar
          jobCounts={jobCounts}
          activeCounts={activeCounts}
          inactive={inactive}
          setList={setList}
          setOperationType={setOperationType}
          setIsLoading={setIsLoading}
          setAlertProps={setAlertProps}
        />

        {/* MAIN CONTENT */}
        <Grid item xs={9} name="object-types-main-container" data-cy="object-types-main-container" overflow="visible">
          { list === 'Assigned' && <ShowAssigned setIsLoading={setIsLoading} setAlertProps={setAlertProps} /> }
          { list === 'Unassigned' && <ShowUnassigned setIsLoading={setIsLoading} setAlertProps={setAlertProps} /> }
          { list === 'Finished' && <ShowFinished setIsLoading={setIsLoading} setAlertProps={setAlertProps} /> }
          { list === 'Operation' && <ShowByOperation setIsLoading={setIsLoading} setAlertProps={setAlertProps} /> }
        </Grid>
      </Grid>
    </>
  );
};

JobsPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
};

export default JobsPage;
