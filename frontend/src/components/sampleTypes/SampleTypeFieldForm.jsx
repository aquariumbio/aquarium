import React, { useState, useEffect } from 'react';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Checkbox from '@material-ui/core/Checkbox';
import Button from '@material-ui/core/Button';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';

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
    <Grid container spacing={1}>
      {/* Titles */}
      <Grid container spacing={1}>
        <Grid container item lg={2}>
          <Typography className={classes.label}>Name</Typography>
        </Grid>

        <Grid item lg={1}>
          <Typography className={classes.label}>Type</Typography>
        </Grid>

        <Grid item lg={1}>
          <Typography className={classes.label}>Required?</Typography>
        </Grid>

        <Grid item lg={1}>
          <Typography className={classes.label}>Array?</Typography>
        </Grid>

        <Grid item lg={2}>
          <Typography className={classes.label}>
            Sample Options (If type=&lsquo;sample&lsquo;)
          </Typography>
        </Grid>

        <Grid item lg={5}>
          <Typography className={classes.label}>Choices</Typography>
        </Grid>
      </Grid>

      {/* Inputs */}
      <Grid container spacing={1}>
        <Grid container item lg={2}>
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
          <TextField
            name="type"
            select
            variant="outlined"
            id="field_type_select"
            value={fieldValue.type}
            onChange={handleChange}
            SelectProps={{
              MenuProps: {
                // open below input
                anchorOrigin: {
                  vertical: 'bottom',
                  horizontal: 'left',
                },
                getContentAnchorEl: null,
              },
            }}
          >
            <MenuItem value="string">string</MenuItem>
            <MenuItem value="number">number</MenuItem>
            <MenuItem value="url">url</MenuItem>
            <MenuItem value="sample">sample</MenuItem>
          </TextField>
        </Grid>

        <Grid item lg={1}>
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
            labelPlacement="end"
          />
        </Grid>

        <Grid item lg={1}>
          <FormControlLabel
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
            labelPlacement="end"
          />
        </Grid>

        <Grid item lg={2}>
          {showSampleOptions ? (
            <Button variant="outlined">
              Add
            </Button>
          ) : (
            <Typography>N/A</Typography>
          )}
        </Grid>

        <Grid item lg={4}>
          {showSampleChoices ? (
            <TextField
              name="choices"
              id="field_choices"
              multiline
              fullWidth
              rows={2}
              variant="outlined"
              helperText="Comma separated. Leave blank for unrestricted value."
              inputProps={{ 'aria-label': 'choices' }}
              value={fieldValue.choices}
              onChange={handleChange}
            />
          ) : (
            <Typography>N/A</Typography>
          )}
        </Grid>
        <Grid item lg={1}>
          <IconButton>
            <CloseIcon />
          </IconButton>
        </Grid>
      </Grid>
    </Grid>
  );
};

export default SampleTypeField;
