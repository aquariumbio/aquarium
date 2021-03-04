import React from 'react';
import PropTypes from 'prop-types';
import TextField from '@material-ui/core/TextField';
import { makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  root: {
    marginBottom: theme.spacing(1),
  },
}));

const TextInput = ({
  name,
  testName = name,
  handleChange,
  value,
  required = false,
  type = 'text',
  autoFocus = false,
}) => {
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
  testName: PropTypes.string,
  handleChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  required: PropTypes.bool,
  type: PropTypes.string,
  autoFocus: PropTypes.bool,
};

export default TextInput;
