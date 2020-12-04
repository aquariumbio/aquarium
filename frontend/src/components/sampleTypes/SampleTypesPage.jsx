/* eslint-disable prefer-template */
/* eslint-disable react/no-array-index-key */
/* eslint-disable no-console */
import { makeStyles } from '@material-ui/core';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import React, { useReducer, useEffect } from 'react';
import { Link } from 'react-router-dom';
import Backdrop from '@material-ui/core/Backdrop';
import CircularProgress from '@material-ui/core/CircularProgress';
import Grid from '@material-ui/core/Grid';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
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

  backdrop: {
    zIndex: theme.zIndex.drawer + 1,
    color: '#fff',
  },
}));

const reducer = (state, newState) => ({ ...state, ...newState });

const SampleTypeDefinitions = () => {
  const classes = useStyles();

  const [state, setState] = useReducer(
    reducer,
    { sampleTypes: [], currentSampleType: {}, isLoading: true },
  );

  useEffect(() => {
    const fetchData = async () => {
      const data = await API.samples.getTypes();

      setState({
        sampleTypes: data.sample_types,
        currentSampleType: data.first,
        isLoading: false,
      });
    };

    fetchData();
  }, []);

  return (
    <>
      <Backdrop className={classes.backdrop} open={state.isLoading}>
        <CircularProgress color="inherit" />
      </Backdrop>
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
        {!state.isloading && (
          <Grid container>
            <Grid item lg={3}>
              <Card className={classes.root}>
                <CardContent>
                  {state.sampleTypes.map((st) => (
                    <Typography key={st.id}>{st.name}</Typography>
                  ))}
                </CardContent>
              </Card>
            </Grid>
            <Grid item lg={9}>
              <Card className={classes.root}>
                <CardContent>
                  {Object.entries(state.currentSampleType).map(
                    ([key, value]) => (
                      <Typography>
                        <b>{key}</b>
                        {': ' + value}
                      </Typography>
                    ),
                  )}
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        )}
      </Paper>
    </>
  );
};
export default SampleTypeDefinitions;
