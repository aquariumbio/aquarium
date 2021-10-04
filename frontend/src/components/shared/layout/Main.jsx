import React from 'react';
import {
  element, arrayOf, oneOfType, string,
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
    height: 'inherit',
    overflow: 'hidden',
    display: 'flex',
    flexDirection: 'column',
  },
  titleArea: {
    paddingRight: theme.spacing(2),
    [theme.breakpoints.down('lg')]: {
      paddingRight: 0,
    },
  },
  scollingContent: {
    flexGrow: 1,
    overflow: 'scroll',
  },
  divider: {
    paddingTop: '30px',
    borderBottom: '1px #DDD solid',
  },
}));

const Main = (props) => {
  const classes = useStyles();
  const { title, children } = props;

  return (
    <Grid item xs className={classes.root} zeroMinWidth>
      <Paper elevation={0} className={classes.paper}>
        <div className={classes.divider} />
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
  children: oneOfType([arrayOf(element), element]),
  title: oneOfType([arrayOf(element), element, string]),

};

Main.defaultProps = {
  children: React.createElement('div'),
  title: null,
};

export default Main;
