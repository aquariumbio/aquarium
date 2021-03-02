import React from 'react';
import PropTypes from 'prop-types';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import TextInput from '../../shared/TextInput';

const ChoicesInput = ({ handleChange, choices, showChoicesInput }) => (
  <Grid item lg={4} data-cy="choices-input-div">
    {showChoicesInput() ? (
      <TextInput name="choices" value={choices} handleChange={handleChange} />
    ) : (
      <Typography>N/A</Typography>
    )}
  </Grid>
);
ChoicesInput.propTypes = {
  handleChange: PropTypes.func.isRequired,
  choices: PropTypes.string.isRequired,
  showChoicesInput: PropTypes.func.isRequired,
};

export default ChoicesInput;
