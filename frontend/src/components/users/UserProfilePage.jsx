import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';

import usersAPI from '../../helpers/api/users';
import Information from './profile/Information';
import Statistics from './profile/Statistics';
import Preferences from './profile/Preferences';
import Memberships from './profile/Memberships';
import Password from './profile/Password';
import LabAgreement from './profile/LabAgreement';
import AquariumAgreement from './profile/AquariumAgreement';
import Page from '../shared/layout/Page';
import Main from '../shared/layout/Main';
import SideBar from '../shared/layout/SideBar';
import ListScroll from '../shared/layout/ListScroll';

// Route: /object_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles(() => ({
  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
}));

// eslint-disable-next-line no-unused-vars
const UserProfilePage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const userId = match.params.id;

  const [currentPage, setCurrentPage] = useState('');

  /* Get object types top populate object options menu
     We cannot use async directly in useEffect so we create an async function that we will call
     from w/in useEffect.
     Our async function gets and sets the objectTypes.
     We only want to fetch data when the component is mounted so we pass an empty array as the
     second argument to useEffect */
  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await usersAPI.getProfile(userId);
      if (!response) return;

      // success
      setCurrentPage('information');
    };

    init();
  }, []);

  return (
    <Page>
      <SideBar>
        <Card>
          <CardContent>
            <ListScroll component="nav" aria-label="sample types list">
              <ListItem
                button
                key="information"
                data-cy="information"
                selected="true"
                onClick={() => setCurrentPage('information')}
              >
                <ListItemText primary="Information" primaryTypographyProps={{ noWrap: true }} />
              </ListItem>

              <ListItem
                button
                key="statistics"
                data-cy="statistics"
                selected={null}
                onClick={() => setCurrentPage('statistics')}
              >
                <ListItemText primary="Statistics" primaryTypographyProps={{ noWrap: true }} />
              </ListItem>

              <ListItem
                button
                key="preferences"
                data-cy="preferences"
                selected={null}
                onClick={() => setCurrentPage('preferences')}
              >
                <ListItemText primary="Preferences" primaryTypographyProps={{ noWrap: true }} />
              </ListItem>

              <ListItem
                button
                key="memberships"
                data-cy="memberships"
                selected={null}
                onClick={() => setCurrentPage('memberships')}
              >
                <ListItemText primary="Memberships" primaryTypographyProps={{ noWrap: true }} />
              </ListItem>

              <ListItem
                button
                key="password"
                data-cy="password"
                selected={null}
                onClick={() => setCurrentPage('password')}
              >
                <ListItemText primary="Change Password" primaryTypographyProps={{ noWrap: true }} />
              </ListItem>

              <ListItem
                button
                key="lab_agreement"
                data-cy="lab_agreement"
                selected={null}
                onClick={() => setCurrentPage('lab_agreement')}
              >
                <ListItemText primary="Lab Agreement" primaryTypographyProps={{ noWrap: true }} />
              </ListItem>

              <ListItem
                button
                key="aquarium_agreement"
                data-cy="aquarium_agreement"
                selected={null}
                onClick={() => setCurrentPage('aquarium_agreement')}
              >
                <ListItemText primary="Aquarium Agreement" primaryTypographyProps={{ noWrap: true }} />
              </ListItem>
            </ListScroll>
          </CardContent>
        </Card>
      </SideBar>

      {/* MAIN CONTENT */}
      <Main>
        { currentPage === 'information' && <Information setIsLoading={setIsLoading} setAlertProps={setAlertProps} id={userId} /> }
        { currentPage === 'statistics' && <Statistics setIsLoading={setIsLoading} setAlertProps={setAlertProps} id={userId} /> }
        { currentPage === 'preferences' && <Preferences setIsLoading={setIsLoading} setAlertProps={setAlertProps} id={userId} /> }
        { currentPage === 'memberships' && <Memberships setIsLoading={setIsLoading} setAlertProps={setAlertProps} id={userId} /> }
        { currentPage === 'password' && <Password setIsLoading={setIsLoading} setAlertProps={setAlertProps} id={userId} /> }
        { currentPage === 'lab_agreement' && <LabAgreement setIsLoading={setIsLoading} setAlertProps={setAlertProps} id={userId} /> }
        { currentPage === 'aquarium_agreement' && <AquariumAgreement setIsLoading={setIsLoading} setAlertProps={setAlertProps} id={userId} /> }
      </Main>
    </Page>
  );
};

UserProfilePage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default UserProfilePage;