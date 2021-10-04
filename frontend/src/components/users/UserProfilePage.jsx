import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useHistory } from 'react-router-dom';

import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';

import usersAPI from '../../helpers/api/usersAPI';
import Information from './profile/Information';
import Permissions from './profile/Permissions';
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
  const history = useHistory();

  const [currentPage, setCurrentPage] = useState('');

  useEffect(() => {
    var search = window.location.search.replace('?','')
    if (['permissions','statistics','preferences','memberships','change_password','lab_agreement','aquarium_agreement'].indexOf(search) == -1) search = 'information'

    setCurrentPage(search)
  }, []);

  const changePage = async (page) => {
    history.push(`/users/${userId}/profile?${page}`.toLowerCase());

    setCurrentPage(page)
  }

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
                key="permissions"
                data-cy="permissions"
                selected={null}
                onClick={() => setCurrentPage('permissions')}
              >
                <ListItemText primary="Permissions" primaryTypographyProps={{ noWrap: true }} />
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
        { currentPage === 'permissions' && <Permissions setIsLoading={setIsLoading} setAlertProps={setAlertProps} id={userId} /> }
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
