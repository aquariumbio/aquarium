import React from 'react';
import {
  element, oneOf, arrayOf, oneOfType, string,
} from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';

const useStyles = makeStyles((theme) => ({
  root: {
    height: 'inherit',
  },
  paper: {
    paddingLeft: theme.spacing(1),
    paddingTop: theme.spacing(1),
    height: 'calc(100% - 40px)',
    overflow: 'hidden',
  },
  titleArea: {
    paddingRight: '10px',
    [theme.breakpoints.down('lg')]: {
      paddingRight: '0px',

    },
  },
  scollingContent: {
    height: 'inherit',
    overflow: 'scroll',
  },
  divider: {
    height: '32px',
    borderBottom: '1px #DDD solid',
    marginBottom: theme.spacing(1),
  },
}));

const Main = (props) => {
  const classes = useStyles();
  const { numOfSections, title, children } = props;

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
    <Grid item xs={flex.xs} lg={flex.lg} className={classes.root}>
      <div className={classes.divider} />{' '}
      <Paper elevation={0} className={classes.paper}>
        {title && (
          <div className={classes.titleArea}>
            {title}
          </div>
        )}
        <div className={classes.scollingContent}>
          {children}
        </div>
      </Paper>
    </Grid>
  );
};

Main.propTypes = {
  numOfSections: oneOf([1, 2, 3]),
  children: oneOfType([arrayOf(element), element]),
  title: oneOfType([arrayOf(element), element, string]),

};

Main.defaultProps = {
  numOfSections: 1,
  children: React.createElement('div'),
  title: null,
};

export default Main;
