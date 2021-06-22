import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import MenuItem from '@material-ui/core/MenuItem';
import TextareaAutosize from '@material-ui/core/TextareaAutosize';
import Alert from '@material-ui/lab/Alert';
import Divider from '@material-ui/core/Divider';

import objectsAPI from '../../helpers/api/objectsAPI';
import sampleTypesAPI from '../../helpers/api/sampleTypesAPI';
import { StandardButton, LinkButton } from '../shared/Buttons';
import Page from '../shared/layout/Page';
import Main from '../shared/layout/Main';
import globalUseSyles from '../../globalUseStyles';

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

// eslint-disable-next-line no-unused-vars
const ObjectTypeForm = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();

  const [disableSubmit, setDisableSubmit] = useState(false);
  const [sampleTypes, setSampleTypes] = useState([]);

  // form variables
  const [id, setId] = useState(null);
  const [objectTypeName, setObjectTypeName] = useState('');
  const [objectTypeDescription, setObjectTypeDescription] = useState('');
  const [objectTypeMin, setObjectTypeMin] = useState('0');
  const [objectTypeMax, setObjectTypeMax] = useState('1');
  const [objectTypeUnit, setObjectTypeUnit] = useState('');
  const [objectTypeCost, setObjectTypeCost] = useState('0.01');
  const [objectTypeHandler, setObjectTypeHandler] = useState('');
  const [objectTypeReleaseMethod, setObjectTypeReleaseMethod] = useState('return');
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

  useEffect(() => {
    const initNew = async () => {
      // wrap the API call
      const response = await sampleTypesAPI.getTypes();
      if (!response) return;

      // success
      setObjectTypeReleaseMethod('return');
      setSampleTypes(response.sample_types);

      if (response.sample_types[0]) {
        setObjectTypeSampleTypeId(response.sample_types[0].id);
      }
    };

    const initEdit = async (thisid) => {
      // wrap the API calls
      const response = await sampleTypesAPI.getTypes();
      if (!response) return;

      // success
      setSampleTypes(response.sample_types);

      // wrap the API calls
      const responses = await objectsAPI.getById(thisid);
      if (!responses) return;

      // success
      const objectType = responses.object_type;

      setId(thisid);
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

    match.params.id ? initEdit(match.params.id) : initNew();
  }, []);

  // Update allowSubmit state if name and Description change
  useEffect(() => {
    setDisableSubmit(
      !objectTypeName.trim() ||
      !objectTypeDescription.trim() ||
      !objectTypeUnit ||
      !objectTypeCost ||
      !objectTypeHandler.trim() ||
      objectTypeMin < 0 ||
      objectTypeMax < 0 ||
      objectTypeMin > objectTypeMax,
    );
  });

  // Submit form with all data
  const handleSubmit = async (event) => {
    event.preventDefault();

    // set formData
    const form = document.querySelector('#object-type-form');
    const data = new FormData(form);
    const formData = Object.fromEntries(data);

    // API call
    const response = id ? await objectsAPI.update(formData, id) : await objectsAPI.create(formData);
    if (!response) return;

    // process errors
    const { errors } = response;
    if (errors) {
      setAlertProps({
        message: JSON.stringify(errors, null, 2),
        severity: 'error',
        open: true,
      });
      return;
    }

    // success
    setAlertProps({
      message: 'Object Type saved/updated',
      severity: 'success',
      open: true,
    });
  };

  return (
    <Page>
      <Main title={(
        <>
          {id ? (
            <>
              <Alert severity="info">
                Note: Changing a object type can have far reaching effects! Edit with care.
              </Alert>
              <Typography variant="h1" align="center" className={classes.title}>
                <u>{objectTypeName}</u>
              </Typography>
              <Typography variant="h2" align="center" className={classes.title}>
                Edit Object Type {id}
              </Typography>
            </>
          ) : (
            <Typography variant="h1" align="center" className={classes.title}>
              New Object Type
            </Typography>
          )}

          <Typography align="right">* field is required</Typography>
        </>
      )}
      >
        <form
          id="object-type-form"
          name="object-type-form"
          data-cy="object-type-form"
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
            type="number"
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
            name="max"
            fullWidth
            value={objectTypeMax}
            id="object-type-max-input"
            onChange={(event) => setObjectTypeMax(event.target.value)}
            variant="outlined"
            type="number"
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
            name="unit"
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
            name="cost"
            fullWidth
            value={objectTypeCost}
            id="object-type-cost-input"
            onChange={(event) => setObjectTypeCost(event.target.value)}
            variant="outlined"
            type="number"
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
            name="handler"
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
            name="release_method"
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
            name="release_description"
            id="object-type-release-description-input"
            style={{ width: '100%' }}
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

          <div className={objectTypeHandler === 'sample_container' ? globalClasses.show : globalClasses.hide}>
            <Typography variant="h4" className={classes.inputName}>
              Sample Type Id
            </Typography>

            <TextField
              name="sample_type_id"
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
                <MenuItem key={sampleType.id} value={sampleType.id}>
                  {sampleType.name}
                </MenuItem>
              ))}
            </TextField>
          </div>

          <Typography variant="h4" className={classes.inputName}>
            Image (Not supported yet)
          </Typography>

          <TextField
            name="image"
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
            name="prefix"
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

          <div className={objectTypeHandler === 'collection' ? globalClasses.show : globalClasses.hide}>
            <Typography variant="h4" className={classes.inputName}>
              Rows
            </Typography>

            <TextField
              name="rows"
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
              name="columns"
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
            name="safety"
            style={{ width: '100%' }}
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
            name="cleanup"
            style={{ width: '100%' }}
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
            name="data"
            style={{ width: '100%' }}
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
            name="vendor"
            style={{ width: '100%' }}
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

          <LinkButton name="back" testName="back" text="All" linkTo="/object_types" />
        </form>
      </Main>
    </Page>
  );
};

ObjectTypeForm.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default ObjectTypeForm;
