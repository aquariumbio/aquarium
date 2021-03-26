import React from 'react';
import PropTypes from 'prop-types';
import Grid from '@material-ui/core/Grid';
import Checkbox from '@material-ui/core/Checkbox';

const RequiredCheckbox = ({ required, handleChange }) => (
  <Grid item lg={1} data-cy="required-checkbox-div">
    <Checkbox
      name="required"
      checked={required}
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

export default RequiredCheckbox;
