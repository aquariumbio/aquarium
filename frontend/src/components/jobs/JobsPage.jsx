import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core';
import SideBar from './SideBar';
import ShowAssigned from './ShowAssigned';
import ShowUnassigned from './ShowUnassigned';
import ShowFinished from './ShowFinished';
import ShowByOperation from './ShowByOperation';
import jobsAPI from '../../helpers/api/jobsAPI';
import HorizontalNavList from './HorizontalNavList';

const useStyles = makeStyles(() => ({
  root: {
    display: 'inline-flex',
    width: '100%',
    height: 'calc(100vh - 75px)',

  },

  whiteSpace: {
    height: '88px',
  },

  main: {
    paddingTop: '25px',
    paddingLeft: '20px',
    width: '100%',
    height: 'calc(100vh - 125px)',
    overflowY: 'auto',
    overflowX: 'hidden',
  },

  divider: {
    marginTop: '0',
  },
}));

const JobsPage = ({ setIsLoading, setAlertProps }) => {
  const classes = useStyles();

  const [value, setValue] = useState('unassigned');
  const [jobCounts, setJobCounts] = useState({});
  const [activeCounts, setActiveCounts] = useState({});
  const [inactive, setInactive] = useState([]);

  const [category, setCategory] = useState('');
  const [operationState, setOperationState] = useState('Pending');
  const [operationType, setOperationType] = useState({});
  const [pendingCount, setPendingCount] = useState();

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

      {/* Jobs & Operations */}
      <SideBar
        jobCounts={jobCounts}
        activeCounts={activeCounts}
        inactive={inactive}
        value={value}
        setValue={setValue}
        category={category}
        setCategory={setCategory}
      />

      <div className={classes.main} name="object-types-main-container" data-cy="object-types-main-container">
        <div className={classes.whiteSpace}>
          {value === 'categories' && (

            // Operation states
            <HorizontalNavList
              name="operation-state-nav"
              list={[{ name: 'Pending' }]}
              value={operationState}
              setValue={setOperationState}
              count={pendingCount}
            />
          )}
        </div>

        {value === 'unassigned' && (
          <ShowUnassigned setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
        )}

        {value === 'assigned' && (
          <ShowAssigned setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
        )}

        {value === 'finished' && (
          <ShowFinished setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
        )}

        { value === 'categories' && (
          <ShowByOperation
            category={category}
            operationType={operationType}
            setOperationType={setOperationType}
            setPendingCount={setPendingCount}
            setAlertProps={setAlertProps}
          />
        )}
      </div>
    </div>
  );
};

JobsPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
};

export default JobsPage;
