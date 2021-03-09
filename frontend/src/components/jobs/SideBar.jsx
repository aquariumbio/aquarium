import React from 'react';
import PropTypes from 'prop-types';

import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Grid from '@material-ui/core/Grid';
import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';

const useStyles = makeStyles(() => ({
  root: {
    height: '100%',
    overflowY: 'scroll',
  },

  pointer: {
    cursor: 'pointer',
  },
}));

// eslint-disable-next-line max-len, no-unused-vars, object-curly-newline
const SideBar = ({ jobCounts, activeCounts, inactive, setList, setOperationType, setIsLoading, setAlertProps }) => {
  const classes = useStyles();

  return (
    <Grid
      item
      xs={3}
      name="job-types-side-bar"
      data-cy="job-types-side-bar"
      className={classes.root}
    >
      <Card>
        <CardContent>
          <div><b>Jobs</b></div>
          <div>
            {/* eslint-disable-next-line jsx-a11y/anchor-is-valid, object-curly-newline */}
            <Link className={classes.pointer} onClick={() => setList('Unassigned')}>Unassigned</Link>
            : ({jobCounts.unassigned})
          </div>
          <div>
            {/* eslint-disable-next-line jsx-a11y/anchor-is-valid, object-curly-newline */}
            <Link className={classes.pointer} onClick={() => setList('Assigned')}>Assigned</Link>
            : ({jobCounts.assigned})
          </div>
          <div>
            {/* eslint-disable-next-line jsx-a11y/anchor-is-valid, object-curly-newline */}
            <Link className={classes.pointer} onClick={() => setList('Finished')}>Finished</Link>
            : ({jobCounts.finished})
          </div>
          <br />
          <div><b>Operations</b></div>
          {Object.keys(activeCounts).map((key) => (
            <div>
              {/* eslint-disable-next-line jsx-a11y/anchor-is-valid, object-curly-newline */}
              <Link className={classes.pointer} onClick={() => { setList('Operation'); setOperationType(`${key}`); }}>{key}</Link>
              : ({activeCounts[`${key}`]})
            </div>
          ))}
          <br />
          <div><b>Inactive</b></div>
          {inactive.map((key) => (
            <div>{key}</div>
          ))}
          <div>...</div>
        </CardContent>
      </Card>
    </Grid>
  );
};

SideBar.propTypes = {
  jobCounts: PropTypes.isRequired,
  activeCounts: PropTypes.isRequired,
  inactive: PropTypes.isRequired,
  setList: PropTypes.isRequired,
  setOperationType: PropTypes.isRequired,
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
};

export default SideBar;
