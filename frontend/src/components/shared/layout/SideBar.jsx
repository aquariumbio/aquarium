import React from 'react';
import {
  element, arrayOf, oneOfType, bool,
} from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';

const useStyles = makeStyles((theme) => ({
  root: {
    maxWidth: '250px',
  },
  small: {
    width: '200px',
  },
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
  const { children, small } = props;
  const classes = useStyles();

  return (
    <Grid item lg={small ? false : 2} className={small ? classes.small : classes.root}>
      <Paper elevation={0} className={`${classes.paper}`}>
        {children}
      </Paper>
    </Grid>
  );
};

SideBar.propTypes = {
  children: oneOfType([arrayOf(element), element]),
  small: bool,
};

SideBar.defaultProps = {
  children: React.createElement('div'),
  small: false,
};

export default SideBar;
