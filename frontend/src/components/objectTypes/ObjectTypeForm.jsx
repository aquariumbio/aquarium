/* eslint-disable no-unused-vars */
import { makeStyles } from '@material-ui/core';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import MenuItem from '@material-ui/core/MenuItem';
import TextareaAutosize from '@material-ui/core/TextareaAutosize';
import React, { useState, useEffect, useRef } from 'react';
import Grid from '@material-ui/core/Grid';
import PropTypes from 'prop-types';
import Alert from '@material-ui/lab/Alert';
import Divider from '@material-ui/core/Divider';
import objectsAPI from '../../helpers/api/objects';
import samplesAPI from '../../helpers/api/samples';
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

const newFieldType = {
  id: null,
  name: '',
  ftype: '',
  required: false,
  array: false,
  choices: '',
  allowable_field_types: [],
};

const ObjectTypeForm = ({ match }) => {
  const classes = useStyles();
  const [isLoading, setIsLoading] = useState(false);
  const [disableSubmit, setDisableSubmit] = useState(false);
  const [alertProps, setAlertProps] = useState({});
  const [sampleTypes, setSampleTypes] = useState([]);

  const [id, setId] = useState(null);
  const [objectTypeName, setObjectTypeName] = useState('');
  const [objectTypeDescription, setObjectTypeDescription] = useState('');
  const [objectTypeMin, setObjectTypeMin] = useState('0');
  const [objectTypeMax, setObjectTypeMax] = useState('1');
  const [objectTypeUnit, setObjectTypeUnit] = useState('');
  const [objectTypeCost, setObjectTypeCost] = useState('0.01');
  const [objectTypeHandler, setObjectTypeHandler] = useState('');
  const [objectTypeReleaseMethod, setObjectTypeReleaseMethod] = useState("return");
  const [objectTypeReleaseDescription, setObjectTypeReleaseDescription] = useState('');
  const [objectTypeSampleTypeId, setObjectTypeSampleTypeId] = useState('');
  const [objectTypeImage, setObjectTypeImage] = useState('');
  const [objectTypePrefix, setObjectTypePrefix] = useState('');
  const [objectTypeRows, setObjectTypeRows] = useState(1);
  const [objectTypeColumns, setObjectTypeColumns] = useState(12);
  const [objectTypeSafety, setObjectTypeSafety] = useState('');
  const [objectTypeCleanup, setObjectTypeCleanup] = useState('');
  const [objectTypeData, setObjectTypeData] = useState('');
  const [objectTypeVendor, setObjectTypeVendor] = useState('');

  const ref = useRef();

  useEffect(() => {
    const initNew = async () => {
      // Start each call asynchronously
      const call1 = samplesAPI.getTypes();
      const call2 = tokensAPI.isPermission(1);

      // Await responses (calls will still run in parallel)
      const response1 = await call1
      const response2 = await call2

      // break if the HTTP call resulted in an error ("return false" from API.js)
      // NOTE: the alert("break") is just there for testing. Whatever processing should be handled in API.js, and we just need stop the system from trying to continue...
      if (!response1 || !response2) {
        alert("break")
        return;
      }

      // success
      setObjectTypeReleaseMethod("return");
      setSampleTypes(response1.sample_types);
      if (response1.sample_types[0]) {
        setObjectTypeSampleTypeId(response1.sample_types[0].id);
      }
    };

    const initEdit = async () => {
      // Start each call asynchronously
      const call1 = samplesAPI.getTypes();
      const call2 = objectsAPI.getById(match.params.id);

      // Await responses (calls will still run in parallel)
      const response1 = await call1
      const response2 = await call2

      // break if the HTTP call resulted in an error ("return false" from API.js)
      // NOTE: the alert("break") is just there for testing. Whatever processing should be handled in API.js, and we just need stop the system from trying to continue...
      if (!response1 || !response2) {
        alert("break")
        return;
      }

      // success
      setSampleTypes(response1.sample_types);

      const objectType = response2.object_type
      setId(objectType.id)
      setObjectTypeName(objectType.name);
      setObjectTypeDescription(objectType.description);
      setObjectTypeMin(objectType.min);
      setObjectTypeMax(objectType.max);
      setObjectTypeUnit(objectType.unit);
      setObjectTypeCost(objectType.cost);
      setObjectTypeHandler(objectType.handler);
      setObjectTypeReleaseMethod(objectType.release_method);
      setObjectTypeReleaseDescription(objectType.release_description);
      setObjectTypeSampleTypeId(objectType.sample_type_id);
      setObjectTypeImage(objectType.image);
      setObjectTypePrefix(objectType.prefix);
      setObjectTypeRows(objectType.rows);
      setObjectTypeColumns(objectType.columns);
      setObjectTypeSafety(objectType.safety);
      setObjectTypeCleanup(objectType.cleanup);
      setObjectTypeData(objectType.data);
      setObjectTypeVendor(objectType.vendor);
    };

    match.params.id ? initEdit() : initNew();
  }, []);

  // Update allowSubmit state if name and Description change
  useEffect(() => {
    setDisableSubmit( false );
  });

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
    // this should use jQuery.serializeArray...
    const formData = {
      id: id,
      name: objectTypeName,
      description: objectTypeDescription,
      min: objectTypeMin,
      max: objectTypeMax,
      handler: objectTypeHandler,
      unit: objectTypeUnit,
      cost: objectTypeCost,
      release_method: objectTypeReleaseMethod,
      release_description: objectTypeReleaseDescription,
      sample_type_id: objectTypeSampleTypeId,
      image: objectTypeImage,
      prefix: objectTypePrefix,
      rows: objectTypeRows,
      columns: objectTypeColumns,
      safety: objectTypeSafety,
      cleanup: objectTypeCleanup,
      data: objectTypeData,
      vendor: objectTypeVendor,
    };
    // change submit action based on form type
    const response = id
      ? await objectsAPI.update(formData, id)
      : await objectsAPI.create(formData);

    // break if the HTTP call resulted in an error ("return false" from API.js)
    // NOTE: the alert("break") is just there for testing. Whatever processing should be handled in API.js, and we just need stop the system from trying to continue...
    if (!response) {
      alert("break")
      return;
    }

    // process errors
    const errors = response["errors"];
    if (errors) {
      setAlertProps({
        message: JSON.stringify(errors, null, 2),
        severity: 'error',
        open: true,
      });
      return;
    }

    // success
    return setAlertProps({
      message: 'Object Type saved/updated',
      severity: 'success',
      open: true,
    });

  };

  return (
    <Container className={classes.root} maxWidth="xl" data-cy="sampe-type-definition-container">
      <LoadingBackdrop isLoading={isLoading} ref={ref} />
      <AlertToast
        open={alertProps.open}
        severity={alertProps.severity}
        message={alertProps.message}
      />

      {match.url === '/object_types/new' && (
        <Typography variant="h1" align="center" className={classes.title}>
          New Object Type
        </Typography>
      )}

      {id && (
        <Typography variant="h1" align="center" className={classes.title}>
          <u>{objectTypeName}</u>
        </Typography>
      )}

      {id && (
        <>
          <Alert severity="info">Note: Changing a object type can have far reaching effects! Edit with care.</Alert>

          <Typography variant="h2" align="center" className={classes.title}>
            Editing Object Type {id}
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
          value={objectTypeName}
          id="object-type-name-input"
          onChange={(event) => setObjectTypeName(event.target.value)}
          variant="outlined"
          autoFocus
          required
          type="string"
          inputProps={{
            'aria-label': 'object-type-name-input',
            'data-cy': 'object-type-name-input',
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
          value={objectTypeDescription}
          id="object-type-description-input"
          onChange={(event) => setObjectTypeDescription(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'object-type-description-input',
            'data-cy': 'object-type-description-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Min
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="min"
          fullWidth
          value={objectTypeMin}
          id="object-type-min-input"
          onChange={(event) => setObjectTypeMin(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'object-type-min-input',
            'data-cy': 'object-type-min-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Max
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="Max"
          fullWidth
          value={objectTypeMax}
          id="object-type-max-input"
          onChange={(event) => setObjectTypeMax(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'object-type-max-input',
            'data-cy': 'object-type-max-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Unit
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="Unit"
          fullWidth
          value={objectTypeUnit}
          id="object-type-unit-input"
          onChange={(event) => setObjectTypeUnit(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'object-type-unit-input',
            'data-cy': 'object-type-unit-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Cost
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="Cost"
          fullWidth
          value={objectTypeCost}
          id="object-type-cost-input"
          onChange={(event) => setObjectTypeCost(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'object-type-cost-input',
            'data-cy': 'object-type-cost-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Handler
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
        </Typography>

        <TextField
          name="Handler"
          fullWidth
          value={objectTypeHandler}
          id="object-type-handler-input"
          onChange={(event) => setObjectTypeHandler(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'object-type-handler-input',
            'data-cy': 'object-type-handler-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName}>
          Release Method
        </Typography>

        <TextField
          name="ReleaseMethod"
          fullWidth
          value={objectTypeReleaseMethod}
          id="object-type-release-method-input"
          onChange={(event) => setObjectTypeReleaseMethod(event.target.value)}
          variant="outlined"
          type="string"
          inputProps={{
            'aria-label': 'object-type-release-method-input',
            'data-cy': 'object-type-release-method-input',
          }}
          select
        >
          <MenuItem value="return">Return</MenuItem>
          <MenuItem value="dispose">Dispose</MenuItem>
          <MenuItem value="query">Query</MenuItem>
        </TextField>

        <Typography variant="h4" className={classes.inputName}>
          Release Description
        </Typography>

        <TextareaAutosize
          name="ReleaseDescription"
          id="object-type-release-description-input"
          style={{width:'100%'}}
          rowsMin={5}
          value={objectTypeReleaseDescription}
          onChange={(event) => setObjectTypeReleaseDescription(event.target.value)}
          variant="outlined"
          type="string"
          required
          inputProps={{
            'aria-label': 'object-type-release-description-input',
            'data-cy': 'object-type-release-description-input',
          }}
        />

        <div className={ objectTypeHandler == 'sample_container' ? classes.show : classes.hide }>
          <Typography variant="h4" className={classes.inputName}>
            Sample Type Id
          </Typography>

          <TextField
            name="SampleTypeId"
            fullWidth
            value={objectTypeSampleTypeId}
            id="object-type-sample-type-id-input"
            onChange={(event) => setObjectTypeSampleTypeId(event.target.value)}
            variant="outlined"
            type="string"
            inputProps={{
              'aria-label': 'object-type-sample-type-id-input',
              'data-cy': 'object-type-sample-type-id-input',
            }}
            select
          >
            {sampleTypes.map((sampleType) => (
              <MenuItem key={sampleType.id} value={sampleType.id}>{sampleType.name}</MenuItem>
            ))}
          </TextField>
        </div>

        <Typography variant="h4" className={classes.inputName}>
          Image (Not supported yet)
        </Typography>

        <TextField
          name="Image"
          fullWidth
          value={objectTypeImage}
          id="object-type-image-input"
          onChange={(event) => setObjectTypeImage(event.target.value)}
          variant="outlined"
          type="string"
          inputProps={{
            'aria-label': 'object-type-image-input',
            'data-cy': 'object-type-image-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName}>
          Prefix
        </Typography>

        <TextField
          name="Prefix"
          fullWidth
          value={objectTypePrefix}
          id="object-type-prefix-input"
          onChange={(event) => setObjectTypePrefix(event.target.value)}
          variant="outlined"
          type="string"
          inputProps={{
            'aria-label': 'object-type-prefix-input',
            'data-cy': 'object-type-prefix-input',
          }}
        />

        <div className={ objectTypeHandler == 'collection' ? classes.show : classes.hide }>
          <Typography variant="h4" className={classes.inputName}>
            Rows
          </Typography>

          <TextField
            name="Rows"
            fullWidth
            value={objectTypeRows}
            id="object-type-rows-input"
            onChange={(event) => setObjectTypeRows(event.target.value)}
            variant="outlined"
            type="string"
            inputProps={{
              'aria-label': 'object-type-rows-input',
              'data-cy': 'object-type-rows-input',
            }}
          />

          <Typography variant="h4" className={classes.inputName}>
            Columns
          </Typography>

          <TextField
            name="Columns"
            fullWidth
            value={objectTypeColumns}
            id="object-type-columns-input"
            onChange={(event) => setObjectTypeColumns(event.target.value)}
            variant="outlined"
            type="string"
            inputProps={{
              'aria-label': 'object-type-columns-input',
              'data-cy': 'object-type-columns-input',
            }}
          />
        </div>

        <Typography variant="h4" className={classes.inputName}>
          Safety
        </Typography>

        <TextareaAutosize
          name="Safety"
          style={{width:'100%'}}
          rowsMin={5}
          value={objectTypeSafety}
          id="object-type-safety-input"
          onChange={(event) => setObjectTypeSafety(event.target.value)}
          variant="outlined"
          type="string"
          inputProps={{
            'aria-label': 'object-type-safety-input',
            'data-cy': 'object-type-safety-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName}>
          Cleanup
        </Typography>

        <TextareaAutosize
          name="Cleanup"
          style={{width:'100%'}}
          rowsMin={5}
          value={objectTypeCleanup}
          id="object-type-cleanup-input"
          onChange={(event) => setObjectTypeCleanup(event.target.value)}
          variant="outlined"
          type="string"
          inputProps={{
            'aria-label': 'object-type-cleanup-input',
            'data-cy': 'object-type-cleanup-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName}>
          Data
        </Typography>

        <TextareaAutosize
          name="Data"
          style={{width:'100%'}}
          rowsMin={5}
          value={objectTypeData}
          id="object-type-data-input"
          onChange={(event) => setObjectTypeData(event.target.value)}
          variant="outlined"
          type="string"
          inputProps={{
            'aria-label': 'object-type-data-input',
            'data-cy': 'object-type-data-input',
          }}
        />

        <Typography variant="h4" className={classes.inputName}>
          Vendor
        </Typography>

        <TextareaAutosize
          name="Vendor"
          style={{width:'100%'}}
          rowsMin={5}
          value={objectTypeVendor}
          id="object-type-vendor-input"
          onChange={(event) => setObjectTypeVendor(event.target.value)}
          variant="outlined"
          type="string"
          inputProps={{
            'aria-label': 'object-type-vendor-input',
            'data-cy': 'object-type-vendor-input',
          }}
        />

        <Divider style={{ marginTop: '0px' }} />

        <StandardButton
          name="save"
          testName="save-object-type"
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
          linkTo="/object_types"
        />
      </form>
    </Container>
  );
};

ObjectTypeForm.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default ObjectTypeForm;
