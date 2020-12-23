import React from 'react';
import PropTypes from 'prop-types';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';

const ChoicesInput = ({ handleChange, choices, showChoicesInput }) => (
  <Grid item lg={4} data-cy="choices-input-div">
    {showChoicesInput ? (
      <TextField
        name="choices"
        id="field-choices"
        multiline
        fullWidth
        variant="outlined"
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

export default ChoicesInput;
