import React from 'react';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import { Redirect } from 'react-router-dom';

const HomePage = () => (
  <>
    { /* every page should make a call */
      !localStorage.getItem('token') && <Redirect to="/login" />
    }
    <Paper elevation={3}>
      <Typography variant="h1">Home</Typography>
    </Paper>
  </>
);

export default HomePage;
