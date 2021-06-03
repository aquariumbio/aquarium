import React from 'react';
import {
  func, element, arrayOf, oneOfType,
} from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';

/*
  The Page component is intended to serve as the base structure for all our app pages
  A page should include a Main component but may also one or two SideBars
  The navBar prop should be a function that returns a NavBar component w/ children
*/

const useStyles = makeStyles(() => ({
  root: {
    flexGrow: 1,
    width: '100%',
    height: 'calc(100vh - 74px)', // (view height - header)
    overflow: 'hide',
  },

  main: {
    width: '100%',
    height: 'calc(100vh - 174px)', // (view height - header & nav bar)
    overflow: 'hidden',
  },
}));

const Page = (props) => {
  const classes = useStyles();
  const { navBar, children } = props;

  return (
    <div className={classes.root}>
      {navBar()}
      <Grid container spacing={1} className={classes.main}>
        {children}
      </Grid>
    </div>
  );
};

Page.propTypes = {
  navBar: func,
  children: oneOfType([arrayOf(element), element]).isRequired,
};

Page.defaultProps = {
  navBar: () => React.createElement('div'),
};

export default Page;

/*
  Example usage:
  const ExamplePage = () => {
    const navBar = () => (
      <NavBar>
        <Typography variant="h4">Example </Typography>
      </NavBar>
    );

    return (
      <Page
        navBar={navBar}
      >
        <SideBar title="Primary Sidebar">
          <ul>
            <li>One</li>
            <li>Two</li>
            <li>Three</li>
          </ul>
        </SideBar>

        <SideBar title="Secondary Sidebar">
          <ul>
            <li>One</li>
            <li>Two</li>
            <li>Three</li>
          </ul>
        </SideBar>

        <Main>
          <div style={{ height: '100px', width: '100px', backgroundColor: 'blue' }} />
          <div style={{ height: '100px', width: '100px', backgroundColor: 'red' }} />
          <div style={{ height: '100px', width: '100px', backgroundColor: 'green' }} />
        </Main>
      </Page>
    );
  };
*/
