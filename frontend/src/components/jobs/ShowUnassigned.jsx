import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';

import jobsAPI from '../../helpers/api/jobs';

const useStyles = makeStyles((theme) => ({
  root: {
    height: 'calc(100% - 64px)',
  },

  inventory: {
    fontSize: '0.875rem',
    marginBottom: theme.spacing(2),
  },

  /* flex */
  flexWrapper: {
    padding: '0 16px',
  },

  flex: {
    display: '-ms-flexbox',
    // eslint-disable-next-line no-dupe-keys
    display: 'flex',
    position: 'relative',
  },

  /* Title row */
  flexTitle: {
    padding: '8px 0',
    borderBottom: '2px solid #c0c0c0',
  },

  /* Data Row */
  flexRow: {
    padding: '8px 0',
    borderBottom: '1px solid #c0c0c0',
    '&:hover': {
      boxShadow: '0 0 3px 0 rgba(0, 0, 0, 0.8)',
    },
  },

  /* Column definiions */
  flexCol1: {
    flex: '1 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol2: {
    flex: '2 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol3: {
    flex: '3 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol4: {
    flex: '4 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexColAuto: {
    width: 'auto',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  /* Use to scale and hide columns in the title row */
  flexColAutoHidden: {
    width: 'auto',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
    visibility: 'hidden',
  },

  show: {
    display: 'block',
  },

  hide: {
    display: 'none',
  },

  pointer: {
    cursor: 'pointer',
  },
}));

// eslint-disable-next-line no-unused-vars
const ShowUnassigned = ({ setList, setIsLoading, setAlertProps }) => {
  const classes = useStyles();

  const [jobs, setJobs] = useState([]);

  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await jobsAPI.getUnassigned();
      if (!response) return;

      // success
      setJobs(response.jobs);
    };

    init();
  }, []);

  return (
    <>
      <div className={classes.flexWrapper}>
        <div className={`${classes.flex} ${classes.flexTitle}`}>
          <Typography className={classes.flexCol2}><b>Protocol</b></Typography>
          <Typography className={classes.flexCol1}><b>Job</b></Typography>
          <Typography className={classes.flexCol1}><b>Operations</b></Typography>
          <Typography className={classes.flexCol1}><b>Created</b></Typography>
        </div>

        {jobs.map((job) => (
          <div className={`${classes.flex} ${classes.flexRow}`} key={`job_${job.id}`}>
            <Typography className={classes.flexCol2}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              {job.name}
            </Typography>
            <Typography className={classes.flexCol1}>
              {job.job_id}
            </Typography>
            <Typography className={classes.flexCol1}>
              {job.operations_count}
            </Typography>
            <Typography className={classes.flexCol1}>
              {job.created_at.substring(0, 16).replace('T', ' ')}
            </Typography>
          </div>
        ))}
      </div>
    </>
  );
};

ShowUnassigned.propTypes = {
  setList: PropTypes.func,
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
};

export default ShowUnassigned;
