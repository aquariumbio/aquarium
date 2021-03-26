import React from 'react';
import PropTypes from 'prop-types';
import Grid from '@material-ui/core/Grid';
import TextInput from '../../shared/TextInput';

const NameInput = ({ name, handleChange, value }) => (
  <Grid item lg={2} data-cy="field-name-input-div">
    <TextInput name={name} value={value} handleChange={handleChange} />
  </Grid>
);
NameInput.propTypes = {
  name: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
  handleChange: PropTypes.func.isRequired,
};

export default NameInput;
