import React, { useState, useEffect } from 'react';
import Typography from '@material-ui/core/Typography';
import globalUseSyles from '../../globalUseStyles';
import { useWindowDimensions } from '../../WindowDimensionsProvider';
import jobsAPI from '../../helpers/api/jobsAPI';
import Main from '../shared/layout/Main';

const ShowUnassigned = () => {
  const globalClasses = globalUseSyles();
  const { tablet } = useWindowDimensions();

  const [jobs, setJobs] = useState([]);

  useEffect(() => {
    const init = async () => {
      const response = await jobsAPI.getUnassigned();
      if (!response) return;

      setJobs(response.jobs);
    };

    init();
  }, []);

  const title = () => (
    <div className={`${globalClasses.flexWrapper}`}>
      <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
        <div className={`${globalClasses.flexCol2}`}>Protocol</div>
        <div className={`${globalClasses.flexCol1}`}>Job</div>
        <div className={`${globalClasses.flexCol1}`}>Operations</div>
        <div className={`${globalClasses.flexCol1}`}>Started</div>
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
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.name}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.job_id}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.operations_count}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.created_at ? job.created_at.substring(0, 16).replace('T', ' ') : '-'}</Typography>
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

export default ShowUnassigned;
