/* eslint-disable no-unused-vars */
import React, { useState, useEffect, useRef } from 'react';
import { useHistory } from 'react-router-dom';
import PropTypes from 'prop-types';

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
import groupsAPI from '../../helpers/api/groups';
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

const GroupForm = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const history = useHistory();

  const [disableSubmit, setDisableSubmit] = useState(false);

  // form variables
  const [id, setId] = useState(null);
  const [groupName, setGroupName] = useState('');
  const [groupDescription, setGroupDescription] = useState('');

  useEffect(() => {
    const initNew = async () => {
      // wrap the API call
      const response = await tokensAPI.isAuthenticated();
      if (!response) return;

      // success
      // noop
    };

    const initEdit = async (thisid) => {
      // wrap the API call
      const response = await groupsAPI.getGroupById(thisid);
      if (!response) return;

      // success
      const group = response.group;
      setId(thisid);
      setGroupName(group.name);
      setGroupDescription(group.description);
    };

    match.params.id ? initEdit(match.params.id) : initNew();
  }, []);

  // Update allowSubmit state
  useEffect(() => {
    setDisableSubmit(
      !groupName.trim() ||
      !groupDescription.trim(),
    );
  });

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();

    // set formData
    const form = document.querySelector('form'); // var
    const data = new FormData(form); // var
    const formData = Object.fromEntries(data);

    const response = id
      ? await groupsAPI.update(formData, id)
      : await groupsAPI.create(formData);
    if (!response) return;

    // process errors
    const errors = response.errors;
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
    history.push('/groups');
  };

  return (
    <Container className={classes.root} maxWidth="xl" data-cy="group-container">
      {
        id ? (
          <>
            <Typography variant="h1" align="center" className={classes.title}>
              <u>{groupName}</u>
            </Typography>
            <Typography variant="h2" align="center" className={classes.title}>
              Editing Group {id}
            </Typography>
          </>
        ) : (
          <Typography variant="h1" align="center" className={classes.title}>
            New Group
          </Typography>
        )
      }
      <Typography align="right">* field is required</Typography>

      <form id="group-form" name="group-form" data-cy="group-form" onSubmit={handleSubmit}>
        <Typography variant="h4" className={classes.inputName} display="inline">
          Name
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="name"
          fullWidth
          value={groupName}
          id="group-name-input"
          onChange={(event) => setGroupName(event.target.value)}
          variant="outlined"
          autoFocus
          required
          type="string"
          inputProps={{
            'aria-label': 'group-name-input',
            'data-cy': 'group-name-input',
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
          value={groupDescription}
          id="group-description-input"
          onChange={(event) => setGroupDescription(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'group-description-input',
            'data-cy': 'group-description-input',
          }}
        />

        <Divider style={{ marginTop: '0px' }} />

        <LinkButton
          name="back"
          testName="back"
          text="Cancel"
          linkTo="/groups"
        />

        <StandardButton
          name="save"
          testName="save-group"
          handleClick={handleSubmit}
          text="Save"
          type="submit"
          disabled={disableSubmit}
          dark
        />
      </form>
    </Container>
  );
};

GroupForm.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default GroupForm;
