import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import Typography from '@material-ui/core/Typography';
import globalUseSyles from '../../globalUseStyles';
import { useWindowDimensions } from '../../WindowDimensionsProvider';
import Main from '../shared/layout/Main';
import jobsAPI from '../../helpers/api/jobsAPI';

const useStyles = makeStyles({
  root: {
    height: 'calc(100% - 64px)',
    width: '100%',
  },
});

// eslint-disable-next-line no-unused-vars
const ShowFinished = () => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();
  const { tablet } = useWindowDimensions();

  const [jobs, setJobs] = useState([]);
  const [sevenDays, setSevenDays] = useState('0');

  const init = async (val) => {
    // wrap the API call
    const response = await jobsAPI.getFinished(val);
    if (!response) return;

    // success
    setJobs(response.jobs);
    setSevenDays(val);
  };

  useEffect(() => {
    init('0');
  }, []);

  const title = () => (
    <div className={`${globalClasses.flexWrapper}`}>
      <TextField
        name="seven-days"
        id="seven-days-input"
        value={sevenDays}
        onChange={(event) => init(event.target.value)}
        variant="outlined"
        type="string"
        inputProps={{
          'aria-label': 'seven-days-input',
          'data-cy': 'seven-days-input',
        }}
        select
        size="small"
      >
        <MenuItem key="1" value="1">Last 7 Days</MenuItem>
        <MenuItem key="0" value="0">All</MenuItem>
      </TextField>

      <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
        <div className={`${globalClasses.flexCol1}`}>Experimenter</div>
        <div className={`${globalClasses.flexCol1}`}>Assigned</div>
        <div className={`${globalClasses.flexCol1}`}>Started</div>
        <div className={`${globalClasses.flexCol1}`}>Finished</div>
        <div className={`${globalClasses.flexCol2}`}>Protocol</div>
        <div className={`${globalClasses.flexCol1}`}>Job#</div>
        <div className={`${globalClasses.flexCol1}`}>Operations</div>
      </div>
    </div>
  );

  const rows = () => {
    if (!jobs) {
      return <div> No finished jobs</div>;
    }

    return (
      jobs.map((job) => (
        <div className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`job_${job.id}`}>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.to_name}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.assigned_date ? job.assigned_date.substring(0, 16).replace('T', ' ') : '-'}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.created_at ? job.created_at.substring(0, 16).replace('T', ' ') : '-'}</Typography>
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{job.updated_at ? job.updated_at.substring(0, 16).replace('T', ' ') : '-'}</Typography>
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

        </div>
      ))
    );
  };

  return (
    <Main title={title()}>
      <div role="grid" aria-label="finished-jobs" className={`${globalClasses.flexWrapper} ${classes.root}`} data-cy="finished-jobs">
        {rows()}
      </div>
    </Main>
  );
};

export default ShowFinished;
