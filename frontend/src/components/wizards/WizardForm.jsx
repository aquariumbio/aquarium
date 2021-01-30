/* eslint-disable no-unused-vars */
import React, { useState, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import { useHistory } from 'react-router-dom';

import { makeStyles } from '@material-ui/core';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import MenuItem from '@material-ui/core/MenuItem';
import TextareaAutosize from '@material-ui/core/TextareaAutosize';
import Grid from '@material-ui/core/Grid';
import Alert from '@material-ui/lab/Alert';
import Divider from '@material-ui/core/Divider';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Checkbox from '@material-ui/core/Checkbox';

import objectsAPI from '../../helpers/api/objects';
import wizardsAPI from '../../helpers/api/wizards';
import tokensAPI from '../../helpers/api/tokens';
import LoadingBackdrop from '../shared/LoadingBackdrop';
import { StandardButton, LinkButton } from '../shared/Buttons';
import utils from '../../helpers/utils';
import AlertToast from '../shared/AlertToast';

const useStyles = makeStyles((theme) => ({
  root: {},

  container: {
    minWidth: 'lg',
    overflow: 'auto',
  },

  title: {
    fontSize: '2.5rem',
    fontWeight: '700',
    marginTop: theme.spacing(1),
    marginBottom: theme.spacing(0.25),
  },

  inputName: {
    fontSize: '1rem',
    fontWeight: '700',
  },

  spaceBelow: {
    marginBottom: theme.spacing(1),
  },

  show: {
    display: 'block',
  },

  hide: {
    display: 'none',
  },
}));

const WizardForm = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const [disableSubmit, setDisableSubmit] = useState(false);
  const history = useHistory();

  const [id, setId] = useState(null);
  const [wizardName, setWizardName] = useState('');
  const [wizardDescription, setWizardDescription] = useState('');
  const [wizardField1Name, setWizardField1Name] = useState('');
  const [wizardField2Name, setWizardField2Name] = useState('');
  const [wizardField2Capacity, setWizardField2Capacity] = useState('');
  const [wizardField3Name, setWizardField3Name] = useState('');
  const [wizardField3Capacity, setWizardField3Capacity] = useState('');

  useEffect(() => {
    const initNew = async () => {
      // wrap the API call
      const response = await tokensAPI.isAuthenticated();
      if (!response) return;

      // success
    };

    const initEdit = async (thisid) => {
      // wrap the API call
      const response = await wizardsAPI.getWizardById(thisid);
      if (!response) return;

      // success
      const wizard = response.wizard;
      setId(thisid);
      setWizardName(wizard.name);
      setWizardDescription(wizard.description);

      const fields = JSON.parse(wizard.specification)['fields'];
      setWizardField1Name(fields['0']['name']);
      setWizardField2Name(fields['1']['name']);
      setWizardField2Capacity(fields['1']['capacity']);
      setWizardField3Name(fields['2']['name']);
      setWizardField3Capacity(fields['2']['capacity']);
    };

    match.params.id ? initEdit(match.params.id) : initNew();
  }, []);

  // Update allowSubmit state
  useEffect(() => {
    setDisableSubmit(
      !wizardName.trim()||
      !wizardDescription.trim()
    );
  });

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();

    // set formData
    const form = document.querySelector('form'); // var
    const data = new FormData(form); // var
    const formData = Object.fromEntries(data);

    // add specification to formData
    // this is custom for Aquarium
    formData['specification'] = {
      fields: {
        0: {
          name: wizardField1Name,
          capacity: -1,
        },
        1: {
          name: wizardField2Name,
          capacity: wizardField2Capacity,
        },
        2: {
          name: wizardField3Name,
          capacity: wizardField3Capacity,
        },
      },
    };

    const response = id
      ? await wizardsAPI.update(formData, id)
      : await wizardsAPI.create(formData);
    if (!response) return;

    // process errors
    const errors = response['errors'];
    if (errors) {
      setAlertProps({
        message: JSON.stringify(errors, null, 2),
        severity: 'error',
        open: true,
      });
      return;
    }

    // success
    // pass alert popup in sessionStorage (does not work if pass as object, so pass as JSON string)
    sessionStorage.alert = JSON.stringify({
      message: id ? 'updated' : 'created',
      severity: 'success',
      open: true,
    });

    history.push('/wizards');
  };

  return (
    <Container className={classes.root} maxWidth="xl" data-cy="wizard-container">
      {
        id ?
          <>
            <Typography variant="h1" align="center" className={classes.title}>
              <u>{wizardName}</u>
            </Typography>
            <Typography variant="h2" align="center" className={classes.title}>
              Editing Wizard {id}
            </Typography>
          </>
        :
          <Typography variant="h1" align="center" className={classes.title}>
            New Wizard
          </Typography>
      }

      <Typography align="right">* field is required</Typography>

      <form id="wizard-form" name="wizard-form" data-cy="wizard-form" onSubmit={handleSubmit}>
        <Typography variant="h4" className={classes.inputName} display="inline">
          Name
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="name"
          fullWidth
          value={wizardName}
          id="wizard-name-input"
          onChange={(event) => setWizardName(event.target.value)}
          variant="outlined"
          autoFocus
          required
          type="string"
          inputProps={{
            'aria-label': 'wizard-name-input',
            'data-cy': 'wizard-name-input',
          }}
          className={classes.spaceBelow}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Description
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="description"
          fullWidth
          value={wizardDescription}
          id="wizard-description-input"
          onChange={(event) => setWizardDescription(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'wizard-description-input',
            'data-cy': 'wizard-description-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Field 1 Name
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="field1Name"
          fullWidth
          value={wizardField1Name}
          id="wizard-field1-name-input"
          onChange={(event) => setWizardField1Name(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'wizard-field1-name-input',
            'data-cy': 'wizard-field1-name-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Field 2 Name
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="field1Name"
          fullWidth
          value={wizardField2Name}
          id="wizard-field2-name-input"
          onChange={(event) => setWizardField2Name(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'wizard-field2-name-input',
            'data-cy': 'wizard-field2-name-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Field 2 Capacity
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="field2Capacity"
          fullWidth
          value={wizardField2Capacity}
          id="wizard-field2-capacity-input"
          onChange={(event) => setWizardField2Capacity(event.target.value)}
          variant="outlined"
          type="number"
          required
          inputProps={{
            'aria-label': 'wizard-field2-capacity-input',
            'data-cy': 'wizard-field2-capacity-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Field 3 Name
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="field3Name"
          fullWidth
          value={wizardField3Name}
          id="wizard-field3-name-input"
          onChange={(event) => setWizardField3Name(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'wizard-field3-name-input',
            'data-cy': 'wizard-field3-name-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Field 3 Capacity
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="field3Capacity"
          fullWidth
          value={wizardField3Capacity}
          id="wizard-field3-capacity-input"
          onChange={(event) => setWizardField3Capacity(event.target.value)}
          variant="outlined"
          type="number"
          required
          inputProps={{
            'aria-label': 'wizard-field3-capacity-input',
            'data-cy': 'wizard-field3-capacity-input',
          }}
        />

        <Divider style={{ marginTop: '0px' }} />

        <StandardButton
          name="save"
          testName="save-wizard"
          handleClick={handleSubmit}
          text="Save"
          type="submit"
          disabled={disableSubmit}
          dark
        />

        <LinkButton
          name="back"
          testName="back"
          text="All"
          linkTo="/wizards"
        />
      </form>
    </Container>
  );
};

WizardForm.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default WizardForm;
