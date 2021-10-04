import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Typography from '@material-ui/core/Typography';
import jobsAPI from '../../helpers/api/jobsAPI';
import globalUseSyles from '../../globalUseStyles';
import { useWindowDimensions } from '../../WindowDimensionsProvider';
import Main from '../shared/layout/Main';

const useStyles = makeStyles({
  root: {
    height: 'calc(100% - 64px)',
    width: '100%',
  },
});

const ShowAssigned = () => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();
  const { tablet } = useWindowDimensions();
  const [jobs, setJobs] = useState([]);

  useEffect(() => {
    const init = async () => {
      const response = await jobsAPI.getAssigned();
      if (!response) return;

      // success
      setJobs(response.jobs);
    };

    init();
  }, []);

  const title = () => (
    <div className={`${globalClasses.flexWrapper}`}>
      <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
        <div className={`${globalClasses.flexCol1}`}>Assigned To</div>
        <div className={`${globalClasses.flexCol2}`}>Protocol</div>
        <div className={`${globalClasses.flexCol1}`}>Job</div>
        <div className={`${globalClasses.flexCol1}`}>Operations</div>
        <div className={`${globalClasses.flexCol1}`}>Started</div>
      </div>
    </div>
  );

  const rows = () => {
    if (!jobs) {
      return <div> No assigned jobs</div>;
    }

    return (
      jobs.map((job) => (
        <div className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`job_${job.id}`}>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.to_name}</Typography>
          </div>
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
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.updated_at ? job.updated_at.substring(0, 16).replace('T', ' ') : '-'}</Typography>
          </div>
        </div>
      ))
    );
  };

  return (
    <Main title={title()}>
      <div role="grid" aria-label="assigned-jobs" className={`${globalClasses.flexWrapper} ${classes.root}`} data-cy="assigned-jobs">
        {rows()}
      </div>
    </Main>
  );
};

export default ShowAssigned;
