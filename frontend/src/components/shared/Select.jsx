import React from 'react';
import PropTypes from 'prop-types';
import MuiSelect from '@material-ui/core/Select';
import MenuItem from '@material-ui/core/MenuItem';

// eslint-disable-next-line object-curly-newline
const Select = ({ name, handleChange, value, options }) => (
  <MuiSelect
    name={name}
    labelId={name}
    variant="outlined"
    value={value}
    defaultValue=""
    onChange={handleChange}
    displayEmpty
    data-cy="select" // Cypress clickable DOM element
    data-testid="select" // Jest clickable DOM element
    inputProps={{
      // input contains the actual value
      'aria-label': `${name}`,
      'data-cy': 'select-input', // Cypress DOM element with value
      'data-testid': 'select-input', // Jest clickable DOM element
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
    <MenuItem value={false} name="select-none" key="select-none" data-testid="select-option">
      Choose one
    </MenuItem>

    {options.map((opt) => (
      <MenuItem value={opt.value} key={opt.name} data-testid="select-option">
        {opt.name}
      </MenuItem>
    ))}
  </MuiSelect>
);
Select.propTypes = {
  name: PropTypes.string.isRequired,
  handleChange: PropTypes.func.isRequired,
  value: PropTypes.PropTypes.oneOfType([PropTypes.string, PropTypes.number, PropTypes.object])
    .isRequired,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string,
      value: PropTypes.oneOfType([PropTypes.string, PropTypes.number, PropTypes.object]),
    }),
  ).isRequired,
};

export default Select;
