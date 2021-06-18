import React from 'react';
import Typography from '@material-ui/core/Typography';
import Page from './shared/layout/Page';
import Main from './shared/layout/Main';

const HomePage = () => (
  <Page>
    <Main>
      <Typography variant="h1">Home</Typography>
    </Main>
  </Page>
);

export default HomePage;
