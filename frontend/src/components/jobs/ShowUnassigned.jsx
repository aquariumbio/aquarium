import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';
import globalUseSyles from '../../globalUseStyles';
import { useWindowDimensions } from '../../WindowDimensionsProvider';
import jobsAPI from '../../helpers/api/jobsAPI';

const useStyles = makeStyles({
  root: {
    height: 'calc(100% - 64px)',
    width: '100%',
  },
});

const ShowUnassigned = () => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();
  const { tablet } = useWindowDimensions();

  const [jobs, setJobs] = useState([]);

  useEffect(() => {
    const init = async () => {
      const response = await jobsAPI.getUnassigned();
      if (!response) return;

      // success
      setJobs(response.jobs);
    };

    init();
  }, []);

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
    <>
      <Divider style={{ marginTop: '0' }} />
      <div role="grid" aria-label="unassigned-jobs" className={`${globalClasses.flexWrapper} ${classes.root}`} data-cy="unassigned-jobs">
        <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
          <div className={`${globalClasses.flexCol2}`}>Protocol</div>
          <div className={`${globalClasses.flexCol1}`}>Job</div>
          <div className={`${globalClasses.flexCol1}`}>Operations</div>
          <div className={`${globalClasses.flexCol1}`}>Started</div>
        </div>
        {rows()}
      </div>
    </>
  );
};

export default ShowUnassigned;
