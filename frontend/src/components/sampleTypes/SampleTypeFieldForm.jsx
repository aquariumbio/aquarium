import React, { useEffect } from 'react';
import Typography from '@material-ui/core/Typography';
import { makeStyles, Select } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
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

export const FieldLabels = () => {
  const classes = useStyles();
  return (
    <div name="field_labels">
      <Grid container item lg={2} cy-data="field_name_label_div">
        <Typography variant="h4" className={classes.label}>
          Field Name
        </Typography>
      </Grid>

      <Grid item lg={1} cy-data="field_type_label_div">
        <Typography variant="h4" className={classes.label}>
          Type
        </Typography>
      </Grid>

      <Grid item lg={1} cy-data="field_is_required_label_div">
        <Typography variant="h4" className={classes.label}>
          Required
        </Typography>
      </Grid>

      <Grid item lg={1} cy-data="field_is_array_label_div">
        <Typography variant="h4" className={classes.label}>
          Array
        </Typography>
      </Grid>

      <Grid item lg={2} cy-data="field_sample_options_label_div">
        <Typography variant="h4" className={classes.label}>
          Sample Options (If type=&lsquo;sample&lsquo;)
        </Typography>
      </Grid>

      <Grid item lg={5} cy-data="field_choices_label_div">
        <Typography variant="h4" className={classes.label}>
          Choices
        </Typography>
      </Grid>
    </div>
  );
};

export const SampleTypeField = (
  {
    fieldType,
    index,
    updateParentState,
    handleRemoveFieldClick,
  },
) => {
  let showSampleSelect = fieldType.type === 'sample';
  let showChoicesInput = fieldType.type === 'string' || fieldType.type === 'number';

  useEffect(() => {
    // Update showSampleOptions & showSampleChoices when fieldType.type changes
    showSampleSelect = fieldType.type === 'sample';
    showChoicesInput = fieldType.type === 'string' || fieldType.type === 'number';
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

  // Fields are not required on sample types so a user should be able add an empty field
  // But if any of the field inputs are not empty or null we want to set some requirements
  // eslint-disable-next-line no-unused-vars
  const fieldRequired = () => {
    const emptyFieldType = {
      id: null,
      name: '',
      type: '',
      isRequired: false,
      isArray: false,
      choices: '',
    };

    return fieldType !== emptyFieldType;
  };

  return (
    <div name="field_inputs">
      <Grid container item lg={2} cy-data="field_name_label_div">
        <TextField
          name="field_name"
          fullWidth
          value={fieldType.name}
          id="field_name"
          onChange={handleChange}
          variant="outlined"
          type="string"
          // TODO: Error HANDLING -- ONLY SHOW HELPER TEXT ON ERROR
        />
      </Grid>

      <Grid item lg={1}>
        <Select
          name="type"
          labelId="type-select-label"
          variant="outlined"
          id="field_type_select"
          value={fieldType.type}
          onChange={handleChange}
          displayEmpty
          inputProps={{ 'aria-label': 'type' }}
          MenuProps={{
            // open below
            anchorOrigin: {
              vertical: 'bottom',
              horizontal: 'left',
            },
            getContentAnchorEl: null,
          }}
          cy-data="field_type_select"
        >
          <MenuItem value="" name="select_none" disabled>
            {' '}
            -
            {' '}
          </MenuItem>
          <MenuItem value="string" name="select_string">
            string
          </MenuItem>
          <MenuItem value="number" name="select_number">
            number
          </MenuItem>
          <MenuItem value="url" name="select_url">
            url
          </MenuItem>
          <MenuItem value="sample" name="select_sample">
            sample
          </MenuItem>
        </Select>
      </Grid>

      <Grid item lg={1} cy-data="is_required_checkbox_div">
        <Checkbox
          name="isRequired"
          value={fieldType.isRequired}
          onClick={handleChange}
          color="primary"
          inputProps={{
            'aria-label': 'Required',
            'cy-data': 'field_is_required_checkbox',
          }}
        />
      </Grid>

      <Grid item lg={1} cy-data="is_array_checkbox_div">
        <Checkbox
          name="isArray"
          value={fieldType.isArray}
          onClick={handleChange}
          color="primary"
          inputProps={{
            'aria-label': 'Array',
            'cy-data': 'field_is_array_checkbox',
          }}
        />
      </Grid>

      <Grid item lg={2} cy-data="samples_div">
        {showSampleSelect ? (
          <Button
            name="add_field_option_btn"
            variant="outlined"
            type="button"
            cy-data="add_field_option_btn"
          >
            Add
          </Button>
        ) : (
          // ADD SAMPLES MENU
          <Typography>N/A</Typography>
        )}
      </Grid>

      <Grid item lg={4} cy-data="choices_input_div">
        {showChoicesInput ? (
          <TextField
            name="choices"
            id="field_choices"
            multiline
            fullWidth
            rows={2}
            variant="outlined"
            helperText="Comma separated. Leave blank for unrestricted value."
            inputProps={{
              'aria-label': 'choices',
              'cy-data': 'add_field_choices_input',
            }}
            value={fieldType.choices}
            onChange={handleChange}
          />
        ) : (
          <Typography>N/A</Typography>
        )}
      </Grid>
      <Grid item lg={1} cy-data="remove_field_btn_div">
        <IconButton
          onClick={handleRemoveFieldClick(index)}
          cy-data="remove_field_btn"
        >
          <CloseIcon />
        </IconButton>
      </Grid>
    </div>
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
