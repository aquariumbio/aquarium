import React from 'react';
import PropTypes from 'prop-types';
import Select from '@material-ui/core/Select';
import Grid from '@material-ui/core/Grid';
import MenuItem from '@material-ui/core/MenuItem';

const FTypeSelect = ({ handleChange, ftype }) => (
  <Grid item lg={1} data-cy="ftype-select-div">
    <Select
      name="ftype"
      variant="outlined"
      defaultValue={ftype}
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
      <MenuItem value="" data-testid="select-none" disabled>
        {' Choose one '}
      </MenuItem>
      <MenuItem value="string" data-testid="select-string">
        string
      </MenuItem>
      <MenuItem value="number" data-testid="select-number">
        number
      </MenuItem>
      <MenuItem value="url" data-testid="select-url">
        url
      </MenuItem>
      <MenuItem value="sample" data-testid="select-sample">
        sample
      </MenuItem>
    </Select>
  </Grid>
);
FTypeSelect.propTypes = {
  handleChange: PropTypes.func.isRequired,
  ftype: PropTypes.string.isRequired,
};

export default FTypeSelect;
