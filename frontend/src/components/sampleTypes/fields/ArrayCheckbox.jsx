import React from 'react';
import PropTypes from 'prop-types';
import Grid from '@material-ui/core/Grid';
import Checkbox from '@material-ui/core/Checkbox';

const ArrayCheckbox = ({ array, handleChange }) => (
  <Grid item lg={1} data-cy="array-checkbox-div">
    <Checkbox
      name="array"
      checked={array}
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

export default ArrayCheckbox;
