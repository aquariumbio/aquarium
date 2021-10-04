import { makeStyles } from '@material-ui/core';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import React, { useState, useEffect } from 'react';
import Grid from '@material-ui/core/Grid';
import PropTypes from 'prop-types';
import Alert from '@material-ui/lab/Alert';
import Divider from '@material-ui/core/Divider';
import SampleTypeFieldForm from './fields/SampleTypeFieldForm';
import FieldLabels from './fields/FieldLabels';
import sampleTypesAPI from '../../helpers/api/sampleTypesAPI';
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
}));

const newFieldType = {
  id: null,
  name: '',
  ftype: '',
  required: false,
  array: false,
  choices: '',
  allowable_field_types: [],
};

const initialSampleType = {
  id: null,
  name: '',
  description: '',
  fieldTypes: [newFieldType],
  objectTypes: [],
  inventory: null,
};

const SampleTypeDefinitionForm = ({ setIsLoading, match }) => {
  const classes = useStyles();

  const [state, setState] = useState({
    sampleType: { ...initialSampleType },
    sampleTypes: [],
    alertProps: {},
  });

  const fetchDataNew = async () => {
    // wrap the API call with the spinner
    const loading = setTimeout(() => { setIsLoading(true); }, window.$timeout);
    const response = await sampleTypesAPI.getTypes();
    clearTimeout(loading);
    setIsLoading(false);
    if (!response) return;

    // success
    setState({
      ...state,
      sampleTypes: [...response.sample_types],
    });
  };

  const fetchDataEdit = async () => {
    // wrap the API call with the spinner
    const loading = setTimeout(() => { setIsLoading(true); }, window.$timeout);
    const getAll = sampleTypesAPI.getTypes();
    const getCurrent = sampleTypesAPI.getTypeById(match.params.id);
    const responseGetAll = await getAll;
    const responseGetCurrent = await getCurrent;
    clearTimeout(loading);
    setIsLoading(false);
    if (!responseGetAll || !responseGetCurrent) return;

    // success
    setState({
      ...state,
      sampleType: {
        ...state.sampleType,
        id: responseGetCurrent.id,
        name: responseGetCurrent.name,
        description: responseGetCurrent.description,
        inventory: responseGetCurrent.inventory,
        fieldTypes: responseGetCurrent.field_types ? responseGetCurrent.field_types : [],
        objectTypes: responseGetCurrent.object_types ? responseGetCurrent.object_types : [],
      },
    });
  };

  /*  Get sample types top populate sample options menu
      We cannot use async directly in useEffect so we create an async function that we will call
      from w/in useEffect.
      Our async function gets and sets the sampleTypes.
      We only want to fetch data when the component is mounted so we pass an empty array as the
      second argument to useEffect  */
  useEffect(() => {
    match.params.id ? fetchDataEdit() : fetchDataNew();
  }, []);

  /*  Disable submit if name or description are empty */
  const invalidName =
    !state.sampleType.name || (!!state.sampleType.name && !state.sampleType.name.trim());
  const invalidDescription =
    !state.sampleType.description ||
    (!!state.sampleType.description && !state.sampleType.description.trim());

  const handleFieldChange = (e) => {
    const { name, value } = e.target;

    setState({
      ...state,
      sampleType: {
        ...state.sampleType,
        [name]: value,
      },
    });
  };

  // Handle click add field button --> add new field type to end of current field types array
  const handleAddFieldClick = () => {
    setState({
      ...state,
      sampleType: {
        ...state.sampleType,
        fieldTypes: [...state.sampleType.fieldTypes, newFieldType],
      },
    });
  };

  // Handle click add new sample to the end of the allowable fields array
  const handleAddAllowableFieldClick = (index) => {
    const fieldTypes = [...state.sampleType.fieldTypes];
    if (fieldTypes[index].allowable_field_types === undefined) {
      fieldTypes[index].allowable_field_types = [];
    }
    fieldTypes[index].allowable_field_types.push({});

    setState({
      ...state,
      sampleType: {
        ...state.sampleType,
        fieldTypes: [...fieldTypes],
      },
    });
  };

  // handle click event of the Remove button
  const handleRemoveFieldClick = (index) => {
    const fieldTypes = [...state.sampleType.fieldTypes];
    fieldTypes.splice(index, 1);

    setState({
      ...state,
      sampleType: {
        ...state.sampleType,
        fieldTypes: [...fieldTypes],
      },
    });
  };

  // handle field type input change
  const handleaNestedInputChange = (value, index) => {
    const fieldTypes = [...state.sampleType.fieldTypes];

    fieldTypes[index] = value;
    setState({
      ...state,
      sampleType: {
        ...state.sampleType,
        fieldTypes: [...fieldTypes],
      },
    });
  };

  const setAlertProps = (alertProps) => {
    setState({
      ...state,
      alertProps: { ...alertProps },
    });
  };

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();
    const formData = {
      id: null,
      name: state.sampleType.name,
      description: state.sampleType.description,
      field_types: state.sampleType.fieldTypes,
    };

    // We will have an id when we are editing a sample type
    const update = !!state.sampleType.id;
    let alertProps;

    // wrap the API call with the spinner
    const loading = setTimeout(() => { setIsLoading(true); }, window.$timeout);
    const response = update
      ? await sampleTypesAPI.update(formData, state.sampleType.id)
      : await sampleTypesAPI.create(formData);
    clearTimeout(loading);
    setIsLoading(false);
    if (!response) return;

    // success
    const action = update ? 'updated' : 'saved';
    if (response.status === 201) {
      alertProps = {
        message: `${state.sampleType.name} ${action}`,
        severity: 'success',
        open: true,
      };
    }

    /*  Failure alert  */
    if (response.status === 200) {
      alertProps = {
        message: `Error: ${state.sampleType.name} could not be ${action}. ${JSON.stringify(
          response.data.errors,
        )}`,
        severity: 'error',
        open: true,
      };
    }

    setAlertProps(alertProps);
  };

  return (
    <Container className={classes.root} maxWidth="xl" data-cy="sampe-type-definition-container">
      <AlertToast
        open={state.alertProps.open}
        severity={state.alertProps.severity}
        message={state.alertProps.message}
        setAlertProps={setAlertProps}
      />

      {match.url === '/sample_types/new' && (
        <Typography variant="h1" align="center" className={classes.title} data-cy="form-header">
          Defining New Sample Type
        </Typography>
      )}

      {state.id && (
        <Typography variant="h1" align="center" className={classes.title}>
          <u>{state.sampleType.name}</u>
          Type Definition
        </Typography>
      )}

      {state.id && (
        <>
          <Alert severity="info">
            Note: Changing a sample type can have far reaching effects! Edit with care.
          </Alert>

          <Typography variant="h2" align="center" className={classes.title}>
            Editing Sample Type
            {state.id}
          </Typography>
        </>
      )}

      <Typography align="right">* field is required</Typography>

      <form
        name="sampe-type-definition-form"
        data-cy="sampe-type-definition-form"
        onSubmit={handleSubmit}
      >
        <Typography variant="h4" className={classes.inputName} display="inline">
          Name
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="name"
          fullWidth
          value={state.sampleType.name}
          id="sample-type-name-input"
          onChange={(event) => handleFieldChange(event)}
          variant="outlined"
          autoFocus
          required
          type="string"
          inputProps={{
            'aria-label': 'sample-type-name-input',
            'data-cy': 'sample-type-name-input',
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
          value={state.sampleType.description}
          id="sample-type-description-input"
          onChange={(event) => handleFieldChange(event)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'sample-type-description-input',
            'data-cy': 'sample-type-description-input',
          }}
        />

        {!!state.sampleType.fieldTypes.length && (
          <Grid container data-cy="fields-container">
            <FieldLabels />
            {
              /* create array of field components */
              state.sampleType.fieldTypes.map((fieldType, index) => (
                // React.Fragment instead of the shorthand <></> so we can use a key
                <React.Fragment key={utils.randString()}>
                  <SampleTypeFieldForm
                    // Composite key of name & random string b/c we allow multiple selections
                    key={`${fieldType.name}-${utils.randString()}`}
                    fieldType={fieldType}
                    sampleTypes={state.sampleTypes}
                    index={index}
                    updateParentState={handleaNestedInputChange}
                    handleRemoveFieldClick={() => handleRemoveFieldClick}
                    handleAddAllowableFieldClick={handleAddAllowableFieldClick}
                  />
                  {
                    /* Add divider below all but last fieldType */
                    index !== state.sampleType.fieldTypes.length - 1 ? (
                      <Grid item xs={12}>
                        <Divider />
                      </Grid>
                    ) : (
                      <></>
                    )
                  }
                </React.Fragment>
              ))
            }
          </Grid>
        )}

        <StandardButton
          name="add-new-field"
          testName="add-new-field"
          handleClick={handleAddFieldClick}
          text="Add New Field"
          dark
        />
        <Divider style={{ marginTop: '0px' }} />

        <StandardButton
          name="save"
          testName="save-sample-type"
          handleClick={handleSubmit}
          text="Save"
          type="submit"
          disabled={invalidName || invalidDescription}
          dark
        />

        <LinkButton name="back" testName="back" text="All" linkTo="/sample_types" />
      </form>
    </Container>
  );
};

SampleTypeDefinitionForm.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default SampleTypeDefinitionForm;
