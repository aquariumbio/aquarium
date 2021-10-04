import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import JobsSideBar from './JobsSideBar';
import ShowAssigned from './ShowAssigned';
import ShowUnassigned from './ShowUnassigned';
import ShowFinished from './ShowFinished';
import ShowByOperation from './ShowByOperation';
import jobsAPI from '../../helpers/api/jobsAPI';
import HorizontalNavList from './HorizontalNavList';
import Page from '../shared/layout/Page';
import NavBar from '../shared/layout/NavBar';

const JobsPage = ({ setIsLoading, setAlertProps }) => {
  const [value, setValue] = useState('unassigned');
  const [jobCounts, setJobCounts] = useState({});
  const [activeCounts, setActiveCounts] = useState({});
  const [inactive, setInactive] = useState([]);

  const [category, setCategory] = useState('');
  const [operationState, setOperationState] = useState('Pending');
  const [operationType, setOperationType] = useState({});
  const [pendingCount, setPendingCount] = useState();

  const init = async () => {
    const response = await jobsAPI.getCounts();

    if (!response) return;

    // success
    setJobCounts(response.counts.jobs);
    setActiveCounts(response.counts.operations.active);
    setInactive(response.counts.operations.inactive);
  };

  useEffect(() => {
    init();
  }, []);

  const cancelJob = async (jobId) => {
    const response = await jobsAPI.cancelJob(jobId);
    if (!response) return;
    await init();
    setAlertProps({
      message: `Job #${jobId} canceled`,
      severity: 'success',
      open: true,
    });
  };

  const removeOperation = async (jobId, opId) => {
    const response = await jobsAPI.removeOperation(jobId, opId);
    if (!response) return;
    await init();
    setAlertProps({
      message: response.message,
      severity: 'success',
      open: true,
    });
  };

  const navBar = () => (
    <NavBar>
      {value === 'categories' ? (
        // Operation states
        <HorizontalNavList
          name="operation-state-nav"
          list={[{ name: 'Pending' }]}
          value={operationState}
          setValue={setOperationState}
          count={pendingCount}
        />
      ) : <></>}
    </NavBar>
  );

  return (
    <Page navBar={navBar}>

      {/* Jobs & Operations */}
      <JobsSideBar
        jobCounts={jobCounts}
        activeCounts={activeCounts}
        inactive={inactive}
        value={value}
        setValue={setValue}
        category={category}
        setCategory={setCategory}
      />
      {value === 'categories' ? (
        <ShowByOperation
          category={category}
          operationType={operationType}
          setOperationType={setOperationType}
          setPendingCount={setPendingCount}
          setAlertProps={setAlertProps}
        />
      ) : (
        <>
          {value === 'unassigned' && (
          <ShowUnassigned
            setIsLoading={setIsLoading}
            setAlertProps={setAlertProps}
            cancelJob={cancelJob}
            removeOperation={removeOperation}
          />
          )}

          {value === 'assigned' && (
          <ShowAssigned setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
          )}

          {value === 'finished' && (
          <ShowFinished setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
          )}
        </>
      )}
    </Page>
  );
};

JobsPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
};

export default JobsPage;
