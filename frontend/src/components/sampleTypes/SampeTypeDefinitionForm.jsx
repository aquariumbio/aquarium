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
import samplesAPI from '../../helpers/api/samples';
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

const initialSampleType = {
  id: null,
  name: '',
  description: '',
};

const newFieldType = {
  id: null,
  name: '',
  ftype: '',
  required: false,
  array: false,
  choices: '',
  allowable_field_types: [],
};

const SampleTypeDefinitionForm = ({ setIsLoading, match }) => {
  const classes = useStyles();
  const [sampleTypeName, setSampleTypeName] = useState(initialSampleType.name);
  const [sampleTypeDescription, setSampleTypeDescription] = useState(initialSampleType.description);
  const [fieldTypes, setFieldTypes] = useState([newFieldType]);
  const [sampleTypes, setSampleTypes] = useState([]);
  const [objectTypes, setObjectTypes] = useState([]);
  const [inventory, setInventory] = useState(0);
  const [id, setId] = useState(null);
  const [disableSubmit, setDisableSubmit] = useState(false);
  const [alertProps, setAlertProps] = useState({});

  /*  Get sample types top populate sample options menu
      We cannot use async directly in useEffect so we create an async function that we will call
      from w/in useEffect.
      Our async function gets and sets the sampleTypes.
      We only want to fetch data when the component is mounted so we pass an empty array as the
      second argument to useEffect  */
  useEffect(() => {
    const fetchDataNew = async () => {
      // loading overlay - use delay (window.$timeout) to avoid screen flash on quick API return
      const loading = setTimeout(() => { setIsLoading(true); }, window.$timeout);

      const response = await samplesAPI.getTypes();

      // break if the HTTP call resulted in an error ("return false" from API.js)
      if (!response) {
        return;
      }

      // clear timeout and clear overlay
      clearTimeout(loading);
      setIsLoading(false);

      // success
      setSampleTypes(response.sample_types);
    };

    const fetchDataEdit = async () => {
      // loading overlay - delay by window.$timeout to avoid screen flash
      const loading = setTimeout(() => { setIsLoading(true); }, window.$timeout);

      //  Make more than one API in parallel
      //  Call both functions
      const getAll = samplesAPI.getTypes();
      const getCurrent = samplesAPI.getTypeById(match.params.id);

      //  Await both responses
      const responseGetAll = await getAll;
      const responseGetCurrent = await getCurrent;

      // break if either API call resulted in an error ("return false" from API.js)
      if (!responseGetAll || !responseGetCurrent) {
        return;
      }

      // clear timeout and clear overlay
      clearTimeout(loading);
      setIsLoading(false);

      // success
      responseGetCurrent.field_types && setFieldTypes(responseGetCurrent.field_types);
      setSampleTypeDescription(responseGetCurrent.description);
      setSampleTypeName(responseGetCurrent.name);
      responseGetCurrent.field_types && setObjectTypes(responseGetCurrent.object_types);
      setInventory(responseGetCurrent.inventory);
      setId(responseGetCurrent.id);
    };

    match.params.id ? fetchDataEdit() : fetchDataNew();
  }, []);

  /*  Update allowSubmit state if name and Description change
      Disable submit if name or description are empty */
  useEffect(() => {
    setDisableSubmit(!sampleTypeName
      || (!!sampleTypeName && !sampleTypeName.trim())
      || !sampleTypeDescription
      || (!!sampleTypeDescription && !sampleTypeDescription.trim()));
  });

  // Handle click add field button --> add new field type to end of current field types array
  const handleAddFieldClick = () => {
    setFieldTypes([...fieldTypes, newFieldType]);
  };

  // Handle click add new sample to the end of the allowable fields array
  const handleAddAllowableFieldClick = (index) => {
    const list = [...fieldTypes];
    if (list[index].allowable_field_types === undefined) {
      list[index].allowable_field_types = [];
    }
    list[index].allowable_field_types.push({});
    setFieldTypes(list);
  };

  // handle click event of the Remove button
  const handleRemoveFieldClick = (index) => {
    const list = [...fieldTypes];
    list.splice(index, 1);
    setFieldTypes(list);
  };

  // handle field type input change
  const handleFieldInputChange = (value, index) => {
    const list = [...fieldTypes];
    list[index] = value;
    setFieldTypes(list);
  };

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();
    const formData = {
      id: null,
      name: sampleTypeName,
      description: sampleTypeDescription,
      field_types: fieldTypes,
    };

    // We will have an id when we are editing a sample type
    const update = !!id;
    let alert;

    // loading overlay - delay by window.$timeout to avoid screen flash
    const loading = setTimeout(() => { setIsLoading(true); }, window.$timeout);

    const response = update
      ? await samplesAPI.update(formData, id)
      : await samplesAPI.create(formData);

    // break if the HTTP call resulted in an error ("return false" from API.js)
    // NOTE: the alert("break") is just there for testing.
    //       whatever processing should be handled in API.js
    //       we just need stop the system from trying to continue...
    if (!response) {
      alert('break');
      return;
    }

    // clear timeout and clear overlay
    clearTimeout(loading);
    setIsLoading(false);

    // success
    const action = update ? 'updated' : 'saved';
    if (response.status === 201) {
      alert = {
        message: `${sampleTypeName} ${action}`,
        severity: 'success',
        open: true,
      };
    }

    /*  Failure alert  */
    if (response.status === 200) {
      alert = {
        message: `Error: ${sampleTypeName} could not be ${action}. ${JSON.stringify(response.data.errors)}`,
        severity: 'error',
        open: true,
      };
    }

    setAlertProps(alert);
  };

  return (
    <Container className={classes.root} maxWidth="xl" data-cy="sampe-type-definition-container">
      <AlertToast
        open={alertProps.open}
        severity={alertProps.severity}
        message={alertProps.message}
        setAlertProps={setAlertProps}
      />

      {match.url === '/sample_types/new' && (
        <Typography variant="h1" align="center" className={classes.title} data-cy="form-header">
          Defining New Sample Type
        </Typography>
      )}

      {id && (
        <Typography variant="h1" align="center" className={classes.title}>
          <u>{sampleTypeName}</u> Type Definition
        </Typography>
      )}

      {id && (
        <>
          <Alert severity="info">Note: Changing a sample type can have far reaching effects! Edit with care.</Alert>

          <Typography variant="h2" align="center" className={classes.title}>
            Editing Sample Type {id}
          </Typography>
        </>
      )}

      <Typography align="right">* field is required</Typography>

      <form name="sampe-type-definition-form" data-cy="sampe-type-definition-form" onSubmit={handleSubmit}>
        <Typography variant="h4" className={classes.inputName} display="inline">
          Name
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="name"
          fullWidth
          value={sampleTypeName}
          id="sample-type-name-input"
          onChange={(event) => setSampleTypeName(event.target.value)}
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
          value={sampleTypeDescription}
          id="sample-type-description-input"
          onChange={(event) => setSampleTypeDescription(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'sample-type-description-input',
            'data-cy': 'sample-type-description-input',
          }}
        />

        {!!fieldTypes.length && (
          <Grid
            container
            data-cy="fields-container"
          >
            <FieldLabels />
            { /* create array of field components */
              fieldTypes.map((fieldType, index) => (
                // React.Fragment instead of the shorthand <></> so we can use a key
                <React.Fragment key={utils.randString()}>
                  <SampleTypeFieldForm
                    // Composite key of name & random string b/c we allow multiple selections
                    key={`${fieldType.name}-${utils.randString()}`}
                    fieldType={fieldType}
                    sampleTypes={sampleTypes}
                    index={index}
                    updateParentState={handleFieldInputChange}
                    handleRemoveFieldClick={() => handleRemoveFieldClick}
                    handleAddAllowableFieldClick={handleAddAllowableFieldClick}
                  />
                  {/* Add divider below all but last fieldType */
                    index !== fieldTypes.length - 1 ? (
                      <Grid item xs={12}>
                        <Divider />
                      </Grid>
                    ) : <></>
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
          disabled={disableSubmit}
          dark

        />

        <LinkButton
          name="back"
          testName="back"
          text="All"
          linkTo="/sample_types"
        />
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
