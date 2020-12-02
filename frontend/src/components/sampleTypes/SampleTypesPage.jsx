import { makeStyles } from '@material-ui/core';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import API from '../../helpers/API';

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

  // Array of sample types
  // eslint-disable-next-line no-unused-vars
  const [sampleTypes, setSampleTypes] = useState([]);

  // Sample type to be shown on right side (form)
  // eslint-disable-next-line no-unused-vars
  const [currentSampleType, setCurrentSampleType] = useState();

  useEffect(() => {
    API.sampleTypes.getSampleTypes(setSampleTypes, setCurrentSampleType);
  });

  const handleClick = (event) => {
    event.preventDefault();
    API.sampleTypes.getSampleTypes(setSampleTypes, setCurrentSampleType);
  };
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
        <Button onClick={handleClick}>BOOP</Button>
      </Paper>
    </>
  );
};
export default SampleTypeDefinitions;
