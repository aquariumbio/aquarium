import React, { useState, useEffect } from 'react';
import { useHistory } from 'react-router-dom';
// eslint-disable-next-line import/no-extraneous-dependencies
import * as queryString from 'query-string';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import Button from '@material-ui/core/Button';

import ShowGroups from './ShowGroups';
import { LinkButton } from '../shared/Buttons';
import groupsAPI from '../../helpers/api/groupsAPI';
import Alphabet from '../shared/Alphabet';
import Page from '../shared/layout/Page';
import Main from '../shared/layout/Main';
import globalUseSyles from '../../globalUseStyles';

// Route: /object_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  wrapper: {
    padding: '0 24px',
  },

  letter: {
    color: theme.palette.primary.main,
  },
}));

// eslint-disable-next-line no-unused-vars
const GroupsPage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();
  const history = useHistory();
  // const [groupLetters, setGroupLetters] = useState([]);

  const [currentLetter, setCurrentLetter] = useState('');
  const [currentGroups, setCurrentGroups] = useState([]);

  const fetchAll = async () => {
    // wrap the API call
    const response = await groupsAPI.getGroups();
    if (!response) return;

    // success
    if (response.groups) {
      setCurrentLetter('All');
      setCurrentGroups(response.groups);
    }
  };

  const fetchLetter = async (letter) => {
    // allows user to hit refresh to reload the page
    // change before calling the API so the URL persists if the token has timed out
    history.push(`/groups?letter=${letter}`.toLowerCase());

    // wrap the API call
    const response = await groupsAPI.getGroupsByLetter(letter);
    if (!response) return;

    // success
    if (response.groups) {
      setCurrentLetter(letter.toUpperCase());
      setCurrentGroups(response.groups);
    }
  };

  // initialize to all and get permissions
  useEffect(() => {
    const init = async () => {
      const letter = queryString.parse(window.location.search).letter;

      if (letter) {
        fetchLetter(letter);
      } else {
        fetchAll();
      }
    };

    init();
  }, []);

  return (
    <Page>
      <Main title={(
        <>
          <Toolbar className={classes.header}>
            <Breadcrumbs
              separator={<NavigateNextIcon fontSize="small" />}
              aria-label="breadcrumb"
              component="div"
              data-cy="page-title"
            >
              <Typography display="inline" variant="h6" component="h1">
                Groups
              </Typography>
              <Typography display="inline" variant="h6" component="h1">
                {currentLetter}
              </Typography>
            </Breadcrumbs>

            <div>
              <LinkButton
                name="New Group"
                testName="new_group_btn"
                text="New Group"
                dark
                type="button"
                linkTo="/groups/new"
              />
            </div>
          </Toolbar>

          <Alphabet fetchLetter={fetchLetter} fetchAll={fetchAll} />

          <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
            <Typography className={globalClasses.flexCol1}><b>Name</b></Typography>
            <Typography className={globalClasses.flexCol3}><b>Description</b></Typography>
            <Typography className={globalClasses.flexColAutoHidden}>Edit</Typography>
            <Typography className={globalClasses.flexColAutoHidden}>Delete</Typography>
          </div>
        </>
      )}
      >
        { currentGroups
          ? <ShowGroups groups={currentGroups} />
          : '' }
      </Main>
    </Page>
  );
};

GroupsPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default GroupsPage;
