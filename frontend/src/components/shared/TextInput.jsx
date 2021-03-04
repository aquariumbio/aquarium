import React from 'react';
import PropTypes from 'prop-types';
import TextField from '@material-ui/core/TextField';
import { makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  root: {
    marginBottom: theme.spacing(1),
  },
}));

const TextInput = ({ name, testName, handleChange, value, required, type, autoFocus }) => {
  const classes = useStyles();

  return (
    <TextField
      name={name}
      key={name}
      defaultValue={value}
      onBlur={handleChange}
      type={type}
      inputProps={{
        'aria-label': name,
        'data-cy': testName,
        'data-testid': testName,
      }}
      required={required}
      fullWidth
      autoFocus={autoFocus}
      variant="outlined"
      className={classes.root}
    />
  );
};

TextInput.propTypes = {
  name: PropTypes.string.isRequired,
  handleChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  required: PropTypes.bool,
  type: PropTypes.string,
  autoFocus: PropTypes.bool,
  testName: PropTypes.string,
};

TextInput.defaultProps = {
  required: false,
  type: 'text',
  autoFocus: false,
  testName: 'Text Input',
};

export default TextInput;
