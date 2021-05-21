import React from 'react';
import {
  string, element, arrayOf, oneOfType,
} from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';

const useStyles = makeStyles((theme) => ({
  paper: {
    paddingLeft: theme.spacing(1),
    paddingTop: theme.spacing(1),
    height: '100%',
    overflowY: 'scroll',
  },
  div: {
    height: '24px',
    borderBottom: '1px #DDD solid',
    marginBottom: theme.spacing(1),
  },
}));

const SideBar = (props) => {
  const { title, children } = props;
  const classes = useStyles();

  return (
    <Grid item xs={3} lg={2} zeroMinWidth>
      <Paper elevation={0} className={`${classes.paper}`}>
        <div className={classes.div}>
          <Typography noWrap variant="subtitle2">{title}</Typography>
        </div>
        {children}
      </Paper>
    </Grid>
  );
};

SideBar.propTypes = {
  title: string,
  children: oneOfType([
    arrayOf(element),
    element,
  ]),
};

SideBar.defaultProps = {
  title: '',
  children: React.createElement('div'),
};

export default SideBar;
