import React from 'react';
import { element, arrayOf, oneOfType } from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import Paper from '@material-ui/core/Paper';

const useStyles = makeStyles((theme) => ({
  root: {
    width: '100%',
    height: '74px',
    padding: theme.spacing(1),
  },
}));

const NavBar = (props) => {
  const { children } = props;
  const classes = useStyles();

  return (
    <Paper elevation={0} className={`${classes.root}`}>
      <Grid container spacing={1}>
        <Grid item xs={3} lg={2}>
          <Paper elevation={0} />
        </Grid>

        <Grid item xs={9} lg={10}>
          <Paper elevation={0}>{children}</Paper>
        </Grid>
      </Grid>
    </Paper>
  );
};

NavBar.propTypes = {
  children: oneOfType([arrayOf(element), element]),
};

NavBar.defaultProps = {
  children: React.createElement('div'),
};

export default NavBar;
