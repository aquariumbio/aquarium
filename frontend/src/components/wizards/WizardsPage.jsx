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

import ShowWizards from './ShowWizards';
import { LinkButton } from '../shared/Buttons';
import wizardsAPI from '../../helpers/api/wizardsAPI';
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

  letter: {
    color: theme.palette.primary.main,
  },
}));

// eslint-disable-next-line no-unused-vars
const WizardsPage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();
  const history = useHistory();

  // const [wizardLetters, setWizardLetters] = useState([]);
  const [currentLetter, setCurrentLetter] = useState('');
  const [currentWizards, setCurrentWizards] = useState([]);

  // initialize to all and get permissions
  useEffect(() => {
    const init = async () => {
      const letter = queryString.parse(window.location.search).letter;

      if (letter) {
        // wrap the API calls
        const responses = await wizardsAPI.getWizardsByLetter(letter);
        if (!responses) return;

        // success
        if (responses.wizards) {
          setCurrentLetter(letter.toUpperCase());
          setCurrentWizards(responses.wizards);
        }
      } else {
        // wrap the API calls
        const responses = await wizardsAPI.getWizards();
        if (!responses) return;

        // success
        if (responses.wizards) {
          setCurrentLetter('All');
          setCurrentWizards(responses.wizards);
        }
      }
    };

    init();
  }, []);

  const fetchAll = async () => {
    // wrap the API call
    const response = await wizardsAPI.getWizards();
    if (!response) return;

    // success
    if (response.wizards) {
      setCurrentLetter('All');
      setCurrentWizards(response.wizards);
    }
  };

  const fetchLetter = async (letter) => {
    // allows user to hit refresh to reload the page
    // change before calling the API so the URL persists if the token has timed out
    history.push(`/wizards?letter=${letter}`.toLowerCase());

    // wrap the API call
    const response = await wizardsAPI.getWizardsByLetter(letter);
    if (!response) return;

    // success
    if (response.wizards) {
      setCurrentLetter(letter.toUpperCase());
      setCurrentWizards(response.wizards);
    }
  };

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
                Wizards
              </Typography>
              <Typography display="inline" variant="h6" component="h1">
                {currentLetter}
              </Typography>
            </Breadcrumbs>

            <div>
              <LinkButton
                name="New Wizard"
                testName="new_wizard_btn"
                text="New"
                dark
                type="button"
                linkTo="/wizards/new"
              />
            </div>
          </Toolbar>

          <Alphabet fetchLetter={fetchLetter} fetchAll={fetchAll} />

          <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
            <Typography className={globalClasses.flexCol1}><b>Name</b></Typography>
            <Typography className={globalClasses.flexCol3}><b>Description</b></Typography>
            <Typography className={globalClasses.flexCol2}><b>Form</b></Typography>
            <Typography className={globalClasses.flexCol1}><b>Ranges</b></Typography>
            <Typography className={globalClasses.flexColAutoHidden}>Edit</Typography>
            <Typography className={globalClasses.flexColAutoHidden}>Delete</Typography>
          </div>
        </>
      )}
      >
        {currentWizards
          ? <ShowWizards wizards={currentWizards} />
          : ''}
      </Main>
    </Page>
  );
};

WizardsPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default WizardsPage;
