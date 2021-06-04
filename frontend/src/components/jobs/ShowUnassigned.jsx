import React, { useState, useEffect } from 'react';
import Typography from '@material-ui/core/Typography';
import CancelOutlinedIcon from '@material-ui/icons/CancelOutlined';
import IconButton from '@material-ui/core/IconButton';
import { func } from 'prop-types';
import Accordion from '@material-ui/core/Accordion';
import AccordionSummary from '@material-ui/core/AccordionSummary';
import AccordionDetails from '@material-ui/core/AccordionDetails';
import ExpandLessIcon from '@material-ui/icons/ExpandLess';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import { makeStyles } from '@material-ui/core';
import globalUseSyles from '../../globalUseStyles';
import jobsAPI from '../../helpers/api/jobsAPI';
import Main from '../shared/layout/Main';
import ShowJobOperations from './ShowJobOperations';

const useStyles = makeStyles((theme) => ({
  root: {
    height: 'calc(100% - 64px)',
    width: '100%',
  },
  accordion: {
    backgroundColor: theme.palette.action.selected,
    margin: 0,
    padding: 0,
  },
  summary: {
    borderTop: '1px',
  },
  details: {
    padding: 0,
    borderTop: '1px solid #DDD',
  },
}));

const ShowUnassigned = (props) => {
  const { cancelJob } = props;
  const classes = useStyles();
  const globalClasses = globalUseSyles();

  const [jobs, setJobs] = useState([]);
  const [expand, setExpand] = useState({});

  const init = async () => {
    const response = await jobsAPI.getUnassigned();
    if (!response) return;
    const expandState = {};
    // eslint-disable-next-line no-return-assign
    response.jobs.forEach((job) => expandState[job.job_id] = { open: false });
    setExpand(expandState);
    setJobs(response.jobs);
  };

  useEffect(() => {
    init();
  }, []);

  const handleCancel = async (jobId) => {
    await cancelJob(jobId);
    init();
  };

  const showOperations = async (jobId) => {
    const job = await jobsAPI.getJob(jobId);
    if (!job) return;
    // eslint-disable-next-line consistent-return
    return job;
  };

  const open = async (jobId) => {
    const { operations } = await showOperations(jobId);
    setExpand({ ...expand, [jobId]: { open: true, content: operations } });
  };

  const close = (jobId) => {
    setExpand({ ...expand, [jobId]: { open: false } });
  };

  // eslint-disable-next-line consistent-return
  const toggleExpand = (jobId) => {
    if (expand[jobId].open) {
      return close(jobId);
    }
    open(jobId);
  };

  const title = () => (
    <div className={`${globalClasses.flexWrapper}`}>
      <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
        <div className={`${globalClasses.flexCol1}`} />
        <div className={`${globalClasses.flexCol2}`}><Typography variant="body2">Protocol</Typography></div>
        <div className={`${globalClasses.flexCol1}`}><Typography variant="body2">Job</Typography></div>
        <div className={`${globalClasses.flexCol1}`}><Typography variant="body2">Operations</Typography></div>
        <div className={`${globalClasses.flexCol1}`}><Typography variant="body2">Created</Typography></div>
        <div className={`${globalClasses.flexCol1}`}><Typography variant="body2" /></div>
      </div>
    </div>
  );

  const rows = () => {
    if (!jobs) {
      return <div> No unassigned jobs</div>;
    }
    return (
      jobs.map((job) => (
        <Accordion
          expanded={expand[job.job_id].open}
          key={job.id}
          TransitionProps={{ unmountOnExit: true }}
          classes={{
            expanded: classes.accordion,
          }}
          square
        >
          <AccordionSummary
            aria-controls="job"
            id={`job_${job.id}`}
            classes={{
              root: classes.summary,
            }}
          >
            <div className={`${globalClasses.flexCol1}`}>
              <IconButton
                aria-label="show operations"
                onClick={() => toggleExpand(job.job_id)}
              >
                {expand[job.job_id].open ? <ExpandLessIcon /> : <ExpandMoreIcon />}
              </IconButton>
            </div>
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
                <CancelOutlinedIcon htmlColor="#FF0000" />
              </IconButton>
            </div>
          </AccordionSummary>
          <AccordionDetails classes={{ root: classes.details }}>
            { !!expand[job.job_id].content &&
              <ShowJobOperations operations={expand[job.job_id].content} />}
          </AccordionDetails>
        </Accordion>
      ))
    );
  };

  return (
    <Main title={title()}>
      <div className={`${globalClasses.flexWrapper} ${classes.root}`} role="grid" aria-label="unassigned-jobs" data-cy="unassigned-jobs">
        {rows()}
      </div>
    </Main>
  );
};

ShowUnassigned.propTypes = {
  cancelJob: func.isRequired,
};

export default ShowUnassigned;
