import React from 'react';
import { element, arrayOf, oneOfType } from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';

const useStyles = makeStyles((theme) => ({
  root: {},
  paper: {
    paddingLeft: theme.spacing(1),
    paddingTop: theme.spacing(1),
    height: 'inherit',
    overflowY: 'hidden',
  },
  div: {
    height: '24px',
    borderBottom: '1px #DDD solid',
    marginBottom: theme.spacing(1),
  },
}));

const SideBar = (props) => {
  const { children } = props;
  const classes = useStyles();

  return (
    <Grid item xs={3} lg={2} zeroMinWidth className={classes.root}>
      <Paper elevation={0} className={`${classes.paper}`}>
        {children}
      </Paper>
    </Grid>
  );
};

SideBar.propTypes = {
  children: oneOfType([arrayOf(element), element]),
};

SideBar.defaultProps = {
  children: React.createElement('div'),
};

export default SideBar;
