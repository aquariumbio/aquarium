import React from 'react';
import PropTypes from 'prop-types';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';

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

export default NameInput;
