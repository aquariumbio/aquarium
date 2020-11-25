import React, { useEffect } from 'react';
import Typography from '@material-ui/core/Typography';
import { makeStyles, Select } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Checkbox from '@material-ui/core/Checkbox';
import Button from '@material-ui/core/Button';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';
import PropTypes from 'prop-types';

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

// eslint-disable-next-line object-curly-newline
const SampleTypeField = ({ fieldType, index, updateParentState, handleRemoveFieldClick }) => {
  const classes = useStyles();

  let showSampleOptions = fieldType.type === 'sample';
  let showSampleChoices = fieldType.type === 'string' || fieldType.type === 'number';

  useEffect(() => {
    // Update showSampleOptions & showSampleChoices when fieldType.type changes
    showSampleOptions = fieldType.type === 'sample';
    showSampleChoices = fieldType.type === 'string' || fieldType.type === 'number';
  });

  // Handle input change: Pass the name and value to the parent callback.
  // If the input is a checkbox we need to use the checked attribute as our value
  const handleChange = (event) => {
    const { name } = event.target;
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    const fieldTypeObj = { ...fieldType };
    fieldTypeObj[name] = value;
    updateParentState(name, value, index);
  };
  // eslint-disable-next-line no-console
  console.log(fieldType);
  return (
    <Grid container spacing={1} cy-data="field_form_container">
      {/* Titles */}
      <>
        <Grid container item lg={2}>
          <Typography variant="h5" className={classes.label}> Field Name</Typography>
        </Grid>

        <Grid item lg={1}>
          <Typography variant="h5" className={classes.label}>Type</Typography>
        </Grid>

        <Grid item lg={1}>
          <Typography variant="h5" className={classes.label}>Required?</Typography>
        </Grid>

        <Grid item lg={1}>
          <Typography variant="h5" className={classes.label}>Array?</Typography>
        </Grid>

        <Grid item lg={2}>
          <Typography variant="h5" className={classes.label}>
            Sample Options (If type=&lsquo;sample&lsquo;)
          </Typography>
        </Grid>

        <Grid item lg={5}>
          <Typography variant="h5" className={classes.label}>Choices</Typography>
        </Grid>
      </>

      {/* Inputs */}
      <>
        <Grid container item lg={2}>
          <TextField
            name="name"
            fullWidth
            value={fieldType.name}
            id="field_name"
            // label="Field name"
            placeholder="Field name"
            onChange={() => handleChange}
            variant="outlined"
            type="string"
            required
            // TODO: Error HANDLING -- ONLY SHOW HELPER TEXT ON ERROR
            helperText="Field name is required."
          />
        </Grid>

        <Grid item lg={1}>
          <Select
            name="type"
            variant="outlined"
            id="field_type_select"
            value={fieldType.type}
            onChange={() => handleChange}
            MenuProps={{
              // open below input
              anchorOrigin: {
                vertical: 'bottom',
                horizontal: 'left',
              },
              getContentAnchorEl: null,
            }}
            cy-data="field_type_select"
          >
            <MenuItem value="string" name="select_string">string</MenuItem>
            <MenuItem value="number" name="select_number">number</MenuItem>
            <MenuItem value="url" name="select_url">url</MenuItem>
            <MenuItem value="sample" name="select_sample">sample</MenuItem>
          </Select>
        </Grid>

        <Grid item lg={1}>
          <FormControlLabel
            style={{ textAlign: 'center' }}
            control={(
              <Checkbox
                name="isRequired"
                value={fieldType.isRequired}
                onChange={() => handleChange}
                color="primary"
                inputProps={{ 'aria-label': 'Required' }}
              />
            )}
            label={fieldType.isRequired.toString()}
            labelPlacement="end"
            cy-data="field_is_required_checkbox"
          />
        </Grid>

        <Grid item lg={1}>
          <FormControlLabel
            control={(
              <Checkbox
                name="isArray"
                value={fieldType.isArray}
                onChange={() => handleChange}
                color="primary"
                inputProps={{ 'aria-label': 'Array' }}
              />
            )}
            label={fieldType.isArray.toString()}
            labelPlacement="end"
            cy-data="field_is_array_checkbox"
          />
        </Grid>

        <Grid item lg={2}>
          {showSampleOptions ? (
            <Button variant="outlined" cy-data="add_field_option_btn">
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
              value={fieldType.choices}
              onChange={() => handleChange}
              cy-data="add_field_option_input"
            />
          ) : (
            <Typography>N/A</Typography>
          )}
        </Grid>
        <Grid item lg={1}>
          <IconButton onClick={handleRemoveFieldClick(index)} cy-data="remove_field_btn">
            <CloseIcon />
          </IconButton>
        </Grid>
      </>
    </Grid>
  );
};

SampleTypeField.propTypes = {
  fieldType: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    type: PropTypes.string,
    isRequired: PropTypes.bool,
    isArray: PropTypes.bool,
    choices: PropTypes.string,
  }).isRequired,
  index: PropTypes.number.isRequired,
  updateParentState: PropTypes.func.isRequired,
  handleRemoveFieldClick: PropTypes.func.isRequired,
};

export default SampleTypeField;
