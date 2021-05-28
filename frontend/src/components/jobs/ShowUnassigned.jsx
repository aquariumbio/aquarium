import React, { useState, useEffect } from 'react';
import Typography from '@material-ui/core/Typography';
import CancelOutlinedIcon from '@material-ui/icons/CancelOutlined';
import IconButton from '@material-ui/core/IconButton';
import { func } from 'prop-types';
import globalUseSyles from '../../globalUseStyles';
import jobsAPI from '../../helpers/api/jobsAPI';
import Main from '../shared/layout/Main';

const ShowUnassigned = (props) => {
  const { cancelJob } = props;
  const globalClasses = globalUseSyles();

  const [jobs, setJobs] = useState([]);

  const init = async () => {
    const response = await jobsAPI.getUnassigned();
    if (!response) return;
    const waitingJobs = response.jobs.filter((job) => job.pc === -1);

    setJobs(waitingJobs);
  };

  useEffect(() => {
    init();
  }, []);

  const handleCancel = async (jobId) => {
    await cancelJob(jobId);
    init();
  };

  const title = () => (
    <div className={`${globalClasses.flexWrapper}`}>
      <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
        <div className={`${globalClasses.flexCol2}`}><Typography variant="body2">Protocol</Typography></div>
        <div className={`${globalClasses.flexCol1}`}><Typography variant="body2">Job</Typography></div>
        <div className={`${globalClasses.flexCol1}`}><Typography variant="body2">Operations</Typography></div>
        <div className={`${globalClasses.flexCol1}`}><Typography variant="body2">Created</Typography></div>
        <div className={`${globalClasses.flexCol1}`}><Typography variant="body2">Cancel</Typography></div>
      </div>
    </div>
  );

  const rows = () => {
    if (!jobs) {
      return <div> No unassigned jobs</div>;
    }
    return (
      jobs.map((job) => (
        <div className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`job_${job.id}`}>
          <div className={`${globalClasses.flexCol2}`}>
            <Typography variant="body2" noWrap>{job.name}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant="body2" noWrap>{job.job_id}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant="body2" noWrap>{job.operations_count}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant="body2" noWrap>{job.created_at ? job.created_at.substring(0, 16).replace('T', ' ') : '-'}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <IconButton aria-label="cancel job" onClick={() => { handleCancel(job.job_id); }}>
              <CancelOutlinedIcon />
            </IconButton>
          </div>
        </div>
      ))
    );
  };

  return (
    <Main numOfSections={2} title={title()}>
      <div role="grid" aria-label="unassigned-jobs" className={`${globalClasses.flexWrapper}`} data-cy="unassigned-jobs">
        {rows()}
      </div>
    </Main>
  );
};

ShowUnassigned.propTypes = {
  cancelJob: func.isRequired,
};

export default ShowUnassigned;
