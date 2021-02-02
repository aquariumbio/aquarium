import React from 'react';
import PropTypes, { object, string } from 'prop-types';
import TextField from '@material-ui/core/TextField';
import { makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  root: {
    marginBottom: theme.spacing(1),
  },
}));

const TextInput = ({ name, testName, onChange, value }) => {
  const classes = useStyles();
  return (
    <TextField
      name={name}
      fullWidth
      value={value}
      onChange={(event) => onChange(event.target.value)}
      variant="outlined"
      autoFocus
      required
      type="string"
      inputProps={{
        'aria-label': name,
        'data-cy': testName,
      }}
      className={classes.root}
    />
  );
};

export default TextInput;

TextInput.propTypes = {
  name: PropTypes.string.isRequired,
  testName: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.oneOfType([string, object]).isRequired,
};
