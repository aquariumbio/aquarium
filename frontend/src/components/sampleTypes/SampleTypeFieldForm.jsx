/* eslint-disable no-console */
/* eslint-disable react/no-array-index-key */
import React, { useEffect } from 'react';
import Typography from '@material-ui/core/Typography';
import { makeStyles, Select } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import Checkbox from '@material-ui/core/Checkbox';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';
import PropTypes from 'prop-types';
import { StandardButton } from '../shared/Buttons';

const useStyles = makeStyles((theme) => ({
  label: {
    fontSize: '0.875rem',
    fontWeight: '700',
    padding: '1px',
  },
  formControl: {
    margin: theme.spacing(1),
    minWidth: 120,
  },
}));

export const FieldLabels = () => {
  const classes = useStyles();
  return (
    // wrap in fragment to maintain grid layout when rendered in parent
    <Grid
      container
      spacing={1}
      style={{ marginTop: '1rem' }}
      data-cy="field-labels"
    >
      <Grid item lg={2} data-cy="field-name-label-div">
        <Typography variant="h4" className={classes.label}>
          Field Name
        </Typography>
      </Grid>

      <Grid item lg={2} data-cy="field-type-label-div">
        <Typography variant="h4" className={classes.label}>
          Type
        </Typography>
      </Grid>

      <Grid item lg={1} data-cy="field-is-required-label-div">
        <Typography variant="h4" className={classes.label}>
          Required
        </Typography>
      </Grid>

      <Grid item lg={1} data-cy="field-is-array-label-div">
        <Typography variant="h4" className={classes.label}>
          Array
        </Typography>
      </Grid>

      <Grid item lg={2} data-cy="field-sample-options-label-div">
        <Typography variant="h4" className={classes.label}>
          Sample Options (If type=&lsquo;sample&lsquo;)
        </Typography>
      </Grid>

      <Grid item lg={3} data-cy="field-choices-label-div">
        <Typography variant="h4" className={classes.label}>
          Choices
        </Typography>
      </Grid>

      <Grid item lg={1} data-cy="field-choices-label-div" />
    </Grid>
  );
};

const NameInput = ({ name, handleChange }) => (
  <Grid item lg={2} data-cy="field-name-input-div">
    <TextField
      name="name"
      fullWidth
      value={name}
      onChange={handleChange}
      variant="outlined"
      inputProps={{
        'aria-label': 'field-name',
        'data-cy': 'field-name-input',
      }}
    />
  </Grid>
);
NameInput.propTypes = {
  name: PropTypes.string.isRequired,
  handleChange: PropTypes.func.isRequired,
};

const SelectType = ({ handleChange, ftype }) => (
  <Grid item lg={2} data-cy="ftype-select-div">
    <Select
      name="ftype"
      labelId="type-select-label"
      variant="outlined"
      value={ftype}
      onChange={handleChange}
      displayEmpty
      data-cy="ftype-select" // Clickable DOM element
      inputProps={{
        'aria-label': 'ftype',
        'data-cy': 'ftype-input', // DOM element with value
      }}
      MenuProps={{
        // open menu below
        anchorOrigin: {
          vertical: 'bottom',
          horizontal: 'left',
        },
        getContentAnchorEl: null,
      }}

    >
      <MenuItem value="" name="select-none" disabled>
        {' Choose one '}
      </MenuItem>
      <MenuItem value="string" name="select-string">
        string
      </MenuItem>
      <MenuItem value="number" name="select-number">
        number
      </MenuItem>
      <MenuItem value="url" name="select-url">
        url
      </MenuItem>
      <MenuItem value="sample" name="select-sample">
        sample
      </MenuItem>
    </Select>
  </Grid>
);
SelectType.propTypes = {
  handleChange: PropTypes.func.isRequired,
  ftype: PropTypes.string.isRequired,
};

const RequiredCheckbox = ({ required, handleChange }) => (
  <Grid item lg={1} data-cy="required-checkbox-div">
    <Checkbox
      name="required"
      value={required}
      onClick={handleChange}
      color="primary"
      inputProps={{
        'aria-label': 'Required',
        'data-cy': 'field-required-checkbox',
      }}
    />
  </Grid>
);
RequiredCheckbox.propTypes = {
  required: PropTypes.bool.isRequired,
  handleChange: PropTypes.func.isRequired,
};

const ArrayCheckbox = ({ array, handleChange }) => (
  <Grid item lg={1} data-cy="array-checkbox-div">
    <Checkbox
      name="array"
      value={array}
      onClick={handleChange}
      color="primary"
      inputProps={{
        'aria-label': 'Array',
        'data-cy': 'array-checkbox',
      }}
    />
  </Grid>
);
ArrayCheckbox.propTypes = {
  array: PropTypes.bool.isRequired,
  handleChange: PropTypes.func.isRequired,
};

const SampleOptionsInput = ({
  handleAddClick,
  handleChange,
  showSampleSelect,
  sampleTypes,
  fieldType,
  index,
}) => (
  <Grid item lg={2} data-cy="samples-div">
    {showSampleSelect ? (
      <>
        <AllowableFieldTypes
          sampleTypes={sampleTypes}
          handleChange={handleChange}
          fieldType={fieldType}
          fieldTypeIndex={index}
        />
        <div style={{ display: 'block' }}>
          <StandardButton
            name="add-field-option-btn"
            variant="outlined"
            testName="add-field-option-btn"
            handleClick={() => handleAddClick(index)}
            text="Add option"
            dense
          />
        </div>
      </>
    ) : (
      <Typography>N/A</Typography>
    )}
  </Grid>
);
SampleOptionsInput.propTypes = {
  handleChange: PropTypes.func.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  // allowableFieldTypes: PropTypes.array.isRequired,
  showSampleSelect: PropTypes.bool.isRequired,
  handleAddClick: PropTypes.func.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  sampleTypes: PropTypes.array.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  fieldType: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
};

const ChoicesInput = ({ handleChange, choices, showChoicesInput }) => (
  <Grid item lg={3} data-cy="choices-input-div">
    {showChoicesInput ? (
      <TextField
        name="choices"
        id="field-choices"
        multiline
        fullWidth
        variant="outlined"
        helperText="Comma separated. Leave blank for unrestricted value."
        inputProps={{
          'aria-label': 'choices',
          'data-cy': 'add-field-choices-input',
        }}
        value={choices}
        onChange={handleChange}
      />
    ) : (
      <Typography>N/A</Typography>
    )}
  </Grid>
);
ChoicesInput.propTypes = {
  handleChange: PropTypes.func.isRequired,
  choices: PropTypes.string.isRequired,
  showChoicesInput: PropTypes.bool.isRequired,
};

const RemoveField = ({ handleRemoveFieldClick, index }) => (
  <Grid item lg={1} data-cy="remove-field-btn-div">
    <IconButton
      onClick={handleRemoveFieldClick(index)}
      data-cy="remove-field-btn"
    >
      <CloseIcon />
    </IconButton>
  </Grid>
);
RemoveField.propTypes = {
  handleRemoveFieldClick: PropTypes.func.isRequired,
  index: PropTypes.number.isRequired,
};

const AllowableFieldTypes = ({
  sampleTypes, handleChange, fieldTypeIndex, fieldType,
}) => (
  <>
    {!!fieldType.allowable_field_types
      && fieldType.allowable_field_types.map((aft, index) => (
        <div style={{ display: 'block' }} key={index}>
          <Select
            style={{ width: 250 }}
            name={`allowableFieldType[${fieldTypeIndex}]`}
            labelId="allowable-field-type-select-label"
            variant="outlined"
            id={`allowable-field-type-select[${index}]`}
            value={aft.name}
            onChange={handleChange}
            displayEmpty
            defaultValue=""
            inputProps={{ 'aria-label': 'allowable-field-type-select-label' }}
            MenuProps={{
              // open below
              anchorOrigin: {
                vertical: 'bottom',
                horizontal: 'left',
              },
              getContentAnchorEl: null,
            }}
            data-cy="allowable-field-type-select-label"
          >
            <MenuItem value="" name="select-none" disabled>
              {' Choose one '}
            </MenuItem>
            {sampleTypes.map((st) => (
              <MenuItem
                key={st.id}
                value={st.name}
                name={`select-${st.name}`}
              >
                {st.name}
              </MenuItem>
            ))}
          </Select>
        </div>
      ))}
  </>
);
AllowableFieldTypes.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  sampleTypes: PropTypes.array.isRequired,
  handleChange: PropTypes.func.isRequired,
  fieldTypeIndex: PropTypes.number.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  fieldType: PropTypes.object.isRequired,
};

export const SampleTypeField = ({
  fieldType,
  index,
  updateParentState,
  handleRemoveFieldClick,
  handleAddAllowableFieldClick,
  sampleTypes,
}) => {
  let showSampleSelect = fieldType.ftype === 'sample';
  let showChoicesInput = fieldType.ftype === 'string' || fieldType.ftype === 'number';

  useEffect(() => {
    // Update showSampleOptions & showSampleChoices when fieldType.ftype changes
    showSampleSelect = fieldType.ftype === 'sample';
    showChoicesInput = fieldType.ftype === 'string' || fieldType.ftype === 'number';
  });

  // Handle input change: Pass the name and value to the parent callback.
  // If the input is a checkbox we need to use the checked attribute as our value
  const handleChange = (event) => {
    const { name } = event.target;
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    const fieldTypeObj = { ...fieldType };
    fieldTypeObj[name] = value;
    // updateParentState(name, value, index);
    updateParentState(fieldTypeObj, index);
  };

  // Fields are not required on sample types so a user should be able add an empty field
  // But if any of the field inputs are not empty or null we want to set some requirements
  // eslint-disable-next-line no-unused-vars
  const fieldRequired = () => {
    const emptyFieldType = {
      id: null,
      name: '',
      ftype: '',
      required: false,
      array: false,
      choices: '',
      allowableFieldTypes: [],
    };

    return fieldType !== emptyFieldType;
  };

  return (
    // wrap in fragment to maintain grid layout when rendered in parent
    <Grid
      container
      spacing={1}
      style={{ marginTop: '1rem' }}
      data-cy="field-inputs"
    >
      <NameInput name={fieldType.name} handleChange={handleChange} />

      <SelectType handleChange={handleChange} ftype={fieldType.ftype} />

      <RequiredCheckbox
        required={fieldType.required}
        handleChange={handleChange}
      />

      <ArrayCheckbox array={fieldType.array} handleChange={handleChange} />

      <SampleOptionsInput
        handleAddClick={handleAddAllowableFieldClick}
        handleChange={handleChange}
        showSampleSelect={showSampleSelect}
        fieldType={fieldType}
        sampleTypes={sampleTypes}
        index={index}
      />

      <ChoicesInput
        handleChange={handleChange}
        choices={fieldType.choices}
        showChoicesInput={showChoicesInput}
      />

      <RemoveField
        handleRemoveFieldClick={handleRemoveFieldClick}
        index={index}
      />
    </Grid>
  );
};

SampleTypeField.propTypes = {
  fieldType: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    ftype: PropTypes.string,
    required: PropTypes.bool,
    array: PropTypes.bool,
    choices: PropTypes.string,
    // eslint-disable-next-line react/forbid-prop-types
    allowable_field_types: PropTypes.array,
  }).isRequired,
  index: PropTypes.number.isRequired,
  updateParentState: PropTypes.func.isRequired,
  handleRemoveFieldClick: PropTypes.func.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  // sampleTypes: PropTypes.array.isRequired,
  handleAddAllowableFieldClick: PropTypes.func.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  sampleTypes: PropTypes.array.isRequired,
};
