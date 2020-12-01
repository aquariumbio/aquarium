import { makeStyles } from '@material-ui/core';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import React from 'react';
import { Link } from 'react-router-dom';

// Route: /sample_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles((theme) => ({
  darkBtn: {
    backgroundColor: '#065683',
    color: 'white',
    margin: theme.spacing(3, 2),

    '& :hover': {
      backgroundColor: 'white',
      color: '#065683',
    },
  },

  lightBtn: {
    backgroundColor: 'white',
    color: '#065683',
    margin: theme.spacing(3, 2),

    '& :hover': {
      backgroundColor: '#065683',
      color: 'white',
    },
  },
}));

const SampleTypeDefinitions = () => {
  const classes = useStyles();
  return (
    <>
      <Paper elevation={3}>
        <Typography variant="h1">Sample Types</Typography>
        <Button
          name="New Sample Type"
          className={classes.darkBtn}
          component={Link} // Wrap Link in button for routing
          to="/sample_types/new"
        >
          New
        </Button>
      </Paper>
    </>
  );
};
export default SampleTypeDefinitions;
