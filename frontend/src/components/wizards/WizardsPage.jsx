/* eslint-disable react/no-array-index-key */
import React, { useState, useEffect } from 'react';
import { useHistory } from 'react-router';
import * as queryString from 'query-string';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import Button from '@material-ui/core/Button';

import ShowWizards from './ShowWizards';
import { LinkButton } from '../shared/Buttons';
import wizardsAPI from '../../helpers/api/wizards';
import permissionsAPI from '../../helpers/api/permissions';

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
    padding: "0 24px",
  },

  letter: {
    color: theme.palette.primary.main,
  },
}));

const WizardsPage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const history = useHistory();

  // const [wizardLetters, setWizardLetters] = useState([]);
  const [currentLetter, setCurrentLetter] = useState('');
  const [currentWizards, setCurrentWizards] = useState([]);

  // initialize to all and get permissions
  useEffect(() => {
    const init = async () => {
      const letter = queryString.parse(window.location.search)['letter'];

      if (letter) {
        // wrap the API calls
        const responses = await wizardsAPI.getWizardsByLetter(letter);
        if (!responses) return;

        // success
        if (responses.wizards) {
          setCurrentLetter(letter.toUpperCase());
          setCurrentWizards(responses['wizards']);
        }
      } else {
        // wrap the API calls
        const responses = await wizardsAPI.getWizards();
        if (!responses) return;

        // success
        if (responses.wizards) {
          setCurrentLetter('All');
          setCurrentWizards(responses['wizards']);
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
      setCurrentWizards(response['wizards']);
    }

    // screen does not refresh (we do not want it to) because only query parameters change
    // allows user to hit refresh to reload
    history.push('/wizards');
  };

  const fetchLetter = async (letter) => {
    // wrap the API call
    const response = await wizardsAPI.getWizardsByLetter(letter);
    if (!response) return;

    // success
    if (response.wizards) {
      setCurrentLetter(letter.toUpperCase());
      setCurrentWizards(response['wizards']);
    }

    // screen does not refresh (we do not want it to) because only query parameters change
    // allows user to hit refresh to reload
    history.push(`/wizards?letter=${letter}`.toLowerCase());
  };

  return (
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

      <Divider />

      <div className={classes.wrapper}>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchAll()}>All</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('A')}>A</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('B')}>B</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('C')}>C</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('D')}>D</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('E')}>E</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('F')}>F</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('G')}>G</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('H')}>H</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('I')}>I</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('J')}>J</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('K')}>K</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('L')}>L</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('M')}>M</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('N')}>N</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('O')}>O</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('P')}>P</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('Q')}>Q</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('R')}>R</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('S')}>S</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('T')}>T</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('U')}>U</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('V')}>V</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('W')}>W</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('X')}>X</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('Y')}>Y</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('Z')}>Z</Button>
        <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('*')}>*</Button>
      </div>

      <Divider />

      {currentWizards
        ? <ShowWizards wizards={currentWizards} />
        : ''}
    </>
  );
};

export default WizardsPage;
