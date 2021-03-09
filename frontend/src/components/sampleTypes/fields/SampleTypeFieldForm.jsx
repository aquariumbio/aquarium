/* eslint-disable react/forbid-prop-types */
import React from 'react';
import PropTypes from 'prop-types';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import FTypeSelect from './FTypeSelect';
import RequiredCheckbox from './RequiredCheckbox';
import ArrayCheckbox from './ArrayCheckbox';
import SampleOptionsInput from './SampleOptionsInput';
import RemoveFieldBtn from './RemoveFieldBtn';
import TextInput from '../../shared/TextInput';

const SampleTypeFieldForm = ({
  fieldType,
  index,
  updateParentState,
  handleRemoveFieldClick,
  handleAddAllowableFieldClick,
  sampleTypes,
}) => {
  const showSampleSelect = () => fieldType.ftype === 'sample';
  const showChoicesInput = () => fieldType.ftype === 'string' || fieldType.ftype === 'number';

  // Handle input change: Pass the name and value to the parent function from props.
  // If the input is a checkbox we need to use the checked attribute as our value.
  // Trim our values to ensure strings don't have leading and trailing white space.
  const handleChange = (event) => {
    const { name } = event.target;
    const value =
      event.target.type === 'checkbox' ? event.target.checked : event.target.value.trim();
    const fieldTypeObj = { ...fieldType };
    fieldTypeObj[name] = value;
    updateParentState(fieldTypeObj, index);
  };

  /*  Fields are not required on sample types so a user should be able add an empty field
      But if any of the field inputs are not empty or null we want to set some requirements */
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
    <Grid container spacing={1} data-cy="field-inputs" data-testid="field-inputs">
      <Grid item lg={2} data-cy="field-name-input-div" role="presentation">
        <TextInput name="name" handleChange={handleChange} value={fieldType.name} />
      </Grid>

      <FTypeSelect handleChange={handleChange} ftype={fieldType.ftype} />

      <RequiredCheckbox required={fieldType.required} handleChange={handleChange} />

      <ArrayCheckbox array={fieldType.array} handleChange={handleChange} />

      <SampleOptionsInput
        handleAddClick={handleAddAllowableFieldClick}
        handleChange={handleChange}
        showSampleSelect={showSampleSelect}
        fieldType={fieldType}
        sampleTypes={sampleTypes}
        index={index}
      />
      <Grid item lg={4} data-cy="choices-input-div">
        {showChoicesInput() ? (
          <TextInput name="choices" value={fieldType.choices} handleChange={handleChange} />
        ) : (
          <Typography data-testid="NA-choices">N/A</Typography>
        )}
      </Grid>

      <RemoveFieldBtn handleRemoveFieldClick={handleRemoveFieldClick} index={index} />
    </Grid>
  );
};

SampleTypeFieldForm.propTypes = {
  fieldType: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    ftype: PropTypes.string,
    required: PropTypes.bool,
    array: PropTypes.bool,
    choices: PropTypes.string,
    allowable_field_types: PropTypes.array,
  }).isRequired,
  index: PropTypes.number.isRequired,
  updateParentState: PropTypes.func.isRequired,
  handleRemoveFieldClick: PropTypes.func.isRequired,
  handleAddAllowableFieldClick: PropTypes.func.isRequired,
  sampleTypes: PropTypes.array.isRequired,
};

export default SampleTypeFieldForm;
