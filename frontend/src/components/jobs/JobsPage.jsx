import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Divider from '@material-ui/core/Divider';
import SideBar from './SideBar';
import ShowAssigned from './ShowAssigned';
import ShowUnassigned from './ShowUnassigned';
import ShowFinished from './ShowFinished';
// import ShowByOperation from './ShowByOperation';
import jobsAPI from '../../helpers/api/jobs';

function TabPanel(props) {
  const {
    children, value, page, id,
  } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== page}
      id={id}
    >
      {children}
    </div>
  );
}

TabPanel.propTypes = {
  children: PropTypes.node.isRequired,
  value: PropTypes.isRequired,
  page: PropTypes.string.isRequired,
  id: PropTypes.isRequired,
};

const useStyles = makeStyles(() => ({
  root: {
    display: 'inline-flex',
    width: '98%',
  },
  main: {
    marginTop: '23px',
    marginLeft: '20px',
    width: '100%',
  },
}));

const JobsPage = ({ setIsLoading, setAlertProps }) => {
  const classes = useStyles();

  // const [operationType, setOperationType] = useState();
  const [jobCounts, setJobCounts] = useState({});
  const [activeCounts, setActiveCounts] = useState({});
  const [inactive, setInactive] = useState([]);
  const [value, setValue] = useState('unassigned');

  useEffect(() => {
    const init = async () => {
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
    <div className={classes.root}>
      <SideBar
        jobCounts={jobCounts}
        activeCounts={activeCounts}
        inactive={inactive}
        value={value}
        setValue={setValue}
        // setOperationType={setOperationType}
        setIsLoading={setIsLoading}
        setAlertProps={setAlertProps}
      />

      <div className={classes.main} name="object-types-main-container" data-cy="object-types-main-container">
        <Divider />

        <TabPanel id="unassigned-jobs-table" value={value} index={0} page="unassigned">
          <ShowUnassigned setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
        </TabPanel>

        <TabPanel id="assigned-jobs-table" value={value} index={1} page="assigned">
          <ShowAssigned setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
        </TabPanel>

        <TabPanel id="finished-jobs-table" value={value} index={2} page="finished">
          <ShowFinished setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
        </TabPanel>

        {/* list === 'Operation' &&
          <ShowByOperation setIsLoading={setIsLoading} setAlertProps={setAlertProps} /> */}
      </div>
    </div>
  );
};

JobsPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
};

export default JobsPage;
