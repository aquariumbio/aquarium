import React, { useState, useEffect } from 'react';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Checkbox from '@material-ui/core/Checkbox';
import Button from '@material-ui/core/Button';

const useStyles = makeStyles((theme) => ({
  label: {
    fontSize: '0.875rem',
    fontWeight: '700',
    padding: '1px',
  },
  formControl: {
    margin: theme.spacing(1),
    minWidth: 120,
  },
  marginTop: {
    marginTop: theme.spacing(1.25),
  },

}));

const SampleTypeField = () => {
  const classes = useStyles();
  const [fieldValue, setFieldValue] = useState({
    name: '',
    type: 'string',
    isRequired: false,
    isArray: false,
    choices: '',
  });
  let showSampleOptions = fieldValue.type === 'sample';
  let showSampleChoices = fieldValue.type === 'string' || fieldValue.type === 'number';

  useEffect(() => {
    // Update showSampleOptions & showSampleChoices when fieldvalue.type changes
    showSampleOptions = fieldValue.type === 'sample';
    showSampleChoices = fieldValue.type === 'string' || fieldValue.type === 'number';
  });

  const handleChange = (event) => {
    setFieldValue({ ...fieldValue, [event.target.name]: event.target.value });
  };

  return (
    <Grid container spacing={1} alignItems="stretch">
      <Grid container item lg={2}>
        <Typography className={classes.label}>
          Name
        </Typography>
        <TextField
          name="name"
          fullWidth
          value={fieldValue.name}
          id="field_name"
          label="Field name"
          placeholder="Field name"
          onChange={handleChange}
          variant="outlined"
          type="string"
          required
          // TODO: Error HANDLING -- ONLY SHOW HELPER TEXT ON ERROR
          helperText="Field name is required."
        />
      </Grid>

      <Grid item lg={1}>
        <Typography className={classes.label}>
          Type
        </Typography>

        <TextField
          name="type"
          select
          variant="outlined"
          labelId="field_type"
          id="field_type_select"
          value={fieldValue.type}
          onChange={handleChange}
          MenuProps={{ // open below input
            anchorOrigin: {
              vertical: 'bottom',
              horizontal: 'left',
            },
            getContentAnchorEl: null,
          }}
        >
          <MenuItem value="string">string</MenuItem>
          <MenuItem value="number">number</MenuItem>
          <MenuItem value="url">url</MenuItem>
          <MenuItem value="sample">sample</MenuItem>
        </TextField>
      </Grid>

      <Grid item>
        <Typography className={classes.label}>
          Required?
        </Typography>
        <FormControlLabel
          style={{ textAlign: 'center' }}
          control={(
            <Checkbox
              name="isRequired"
              value={fieldValue.isRequired}
              onChange={handleChange}
              color="primary"
              inputProps={{ 'aria-label': 'Required' }}
            />
          )}
          label={fieldValue.isRequired.toString()}
          labelPlacement="bottom"
        />
      </Grid>

      <Grid item>
        <Typography className={classes.label}>
          Array?
        </Typography>
        <FormControlLabel
          style={{ textAlign: 'center' }}
          control={(
            <Checkbox
              name="isArray"
              value={fieldValue.isArray}
              onChange={handleChange}
              color="primary"
              inputProps={{ 'aria-label': 'Array' }}
            />
          )}
          label={fieldValue.isArray.toString()}
          labelPlacement="bottom"
        />
      </Grid>

      <Grid item lg={2}>
        <Typography className={classes.label}>
          Sample Options (If type=&lsquo;sample&lsquo;)
        </Typography>

        { showSampleOptions
          ? <Button variant="outlined" className={classes.marginTop}>Add</Button>
          : <Typography className={classes.marginTop}>N/A</Typography>}
      </Grid>

      <Grid item lg={5}>
        <Typography className={classes.label}>
          Choices
        </Typography>
        { showSampleChoices
          ? (
            <TextField
              name="choices"
              id="field_choices"
              multiline
              rows={2}
              variant="outlined"
              helperText="Comma separated. Leave blank for unrestricted value."
              inputProps={{ 'aria-label': 'choices' }}
              value={fieldValue.choices}
              onChange={handleChange}
              className={classes.marginTop}
            />
          )
          : <Typography className={classes.marginTop}>N/A</Typography>}
      </Grid>
    </Grid>
  );
};

export default SampleTypeField;
