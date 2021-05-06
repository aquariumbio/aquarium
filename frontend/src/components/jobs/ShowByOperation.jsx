// import React, { useState, useEffect } from 'react';
import React, { useState } from 'react';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';

// import jobsAPI from '../../helpers/api/jobs';

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
const ShowByOperation = ({ setList, setIsLoading, setAlertProps }) => {
  const classes = useStyles();

  // eslint-disable-next-line no-unused-vars
  const [jobs, setJobs] = useState([]);

  return (
    <>
      <div className={classes.flexWrapper}>
        <div className={`${classes.flex} ${classes.flexTitle}`}>
          <Typography className={classes.flexCol1}><b>Plan</b></Typography>
          <Typography className={classes.flexCol1}><b>Input/Output</b></Typography>
          <Typography className={classes.flexCol1}><b>Updated</b></Typography>
          <Typography className={classes.flexCol1}><b>Researcher</b></Typography>
          <Typography className={classes.flexCol1}><b>Op Id</b></Typography>
          <Typography className={classes.flexCol1}><b>Status</b></Typography>
        </div>

        <div className={`${classes.flex} ${classes.flexRow}`}>
          <Typography className={classes.flexCol1}>...</Typography>
          <Typography className={classes.flexCol1}>...</Typography>
          <Typography className={classes.flexCol1}>...</Typography>
          <Typography className={classes.flexCol1}>...</Typography>
          <Typography className={classes.flexCol1}>...</Typography>
          <Typography className={classes.flexCol1}>...</Typography>
        </div>

        {jobs.map((job) => (
          <div className={`${classes.flex} ${classes.flexRow}`} key={`job_${job.id}`}>
            <Typography className={classes.flexCol1}>
              ...
            </Typography>
            <Typography className={classes.flexCol1}>
              ...
            </Typography>
            <Typography className={classes.flexCol1}>
              ...
            </Typography>
            <Typography className={classes.flexCol1}>
              ...
            </Typography>
            <Typography className={classes.flexCol1}>
              ...
            </Typography>
            <Typography className={classes.flexCol1}>
              ...
            </Typography>
          </div>
        ))}
      </div>
    </>
  );
};

ShowByOperation.propTypes = {
  setList: PropTypes.func,
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
};

export default ShowByOperation;
