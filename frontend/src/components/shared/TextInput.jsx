import React from 'react';
import PropTypes, { object, string } from 'prop-types';
import TextField from '@material-ui/core/TextField';
import { makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  root: {
    marginBottom: theme.spacing(1),
  },
}));

const TextInput = ({
  name,
  testName,
  onChange,
  value,
  required = false,
  type = string,
  autoFocus = false,
}) => {
  const classes = useStyles();

  return (
    <TextField
      name={name}
      key={name}
      value={value}
      onChange={(event) => onChange(event)}
      type={type}
      inputProps={{
        'aria-label': name,
        'data-cy': testName,
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
  testName: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.oneOfType([string, object]).isRequired,
  required: PropTypes.bool,
  type: PropTypes.string,
  autoFocus: PropTypes.bool,
};

export default TextInput;
