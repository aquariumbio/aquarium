import React from 'react';
import {
  element, oneOf, arrayOf, oneOfType,
} from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';

const useStyles = makeStyles((theme) => ({
  paper: {
    paddingLeft: theme.spacing(1),
    paddingTop: theme.spacing(1),
    height: '100%',
    overflow: 'scroll',
  },
  divider: {
    height: '24px',
    borderBottom: '1px #DDD solid',
    marginBottom: theme.spacing(1),
  },
}));

const Main = (props) => {
  const classes = useStyles();
  const { numOfSections, children } = props;

  // Default to large sigle section
  let flex = {
    xs: 12,
    lg: 12,
  };

  // Reduce main section size to accomodate more sections
  if (numOfSections === 2) {
    flex = {
      xs: 9,
      lg: 10,
    };
  } else if (numOfSections === 3) {
    flex = {
      xs: 6,
      lg: 8,
    };
  }

  return (
    <Grid item xs={flex.xs} lg={flex.lg}>
      <Paper elevation={0} className={classes.paper}>
        <div className={classes.divider} /> {/* Hold space so align dividers across sections */}
        {children}
      </Paper>
    </Grid>
  );
};

Main.propTypes = {
  numOfSections: oneOf([1, 2, 3]),
  children: oneOfType([
    arrayOf(element),
    element,
  ]),
};

Main.defaultProps = {
  numOfSections: 1,
  children: React.createElement('div'),
};

export default Main;
