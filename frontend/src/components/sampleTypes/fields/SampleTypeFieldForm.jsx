import React, { useEffect } from 'react';
import PropTypes from 'prop-types';

import Grid from '@material-ui/core/Grid';

import ChoicesInput from './ChoicesInput';
import NameInput from './NameInput';
import FTypeSelect from './FTypeSelect';
import RequiredCheckbox from './RequiredCheckbox';
import ArrayCheckbox from './ArrayCheckbox';
import SampleOptionsInput from './SampleOptionsInput';
import RemoveFieldBtn from './RemoveFieldBtn';

const SampleTypeFieldForm = ({
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

  // Handle input change: Pass the name and value to the parent function from props.
  // If the input is a checkbox we need to use the checked attribute as our value.
  // Trim our values to ensure strings don't have leading and trailing white space.
  const handleChange = (event) => {
    const { name } = event.target;
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value.trim();
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
    <Grid
      container
      spacing={1}
      data-cy="field-inputs"
    >
      <NameInput name={fieldType.name} handleChange={handleChange} />

      <FTypeSelect handleChange={handleChange} ftype={fieldType.ftype} />

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

      <RemoveFieldBtn
        handleRemoveFieldClick={handleRemoveFieldClick}
        index={index}
      />
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

export default SampleTypeFieldForm;
