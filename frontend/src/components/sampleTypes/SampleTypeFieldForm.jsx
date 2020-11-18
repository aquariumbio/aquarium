import React, { useState } from 'react';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import TextField from '@material-ui/core/TextField';
import InputLabel from '@material-ui/core/InputLabel';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Select from '@material-ui/core/Select';
import Checkbox from '@material-ui/core/Checkbox';

const useStyles = makeStyles(() => ({
  fieldCont: {
    display: 'inline-flex',
  },
  fieldName: {
    fontSize: '0.875rem',
    fontWeight: '700',
    padding: '1px',
  },
}));

const SampleTypeField = () => {
  const classes = useStyles();
  const [fieldName, setFieldName] = useState();
  const [fieldType, setFieldType] = useState();
  const [isRequired, setIsRequired] = useState(false);
  const [isArray, setIsArray] = useState(false);

  return (
    <Grid container spacing={3}>
      <Grid item xl={12} lg={6}>
        <Typography className={classes.fieldName}>
          Name
        </Typography>
        <TextField
          name="field_name"
          fullWidth
          value={fieldName}
          id="field_name"
          label="Field name"
          placeholder="Field name"
          onChange={(event) => setFieldName(event.target.value)}
          variant="outlined"
          type="string"
          required
          // TODO: Error HANDLING -- ONLY SHOW HELPER TEXT ON ERROR
          helperText="Field name is required."
        />
      </Grid>

      <Grid item>
        <Typography className={classes.fieldName}>
          Type
        </Typography>
        <FormControl variant="outlined" className={classes.formControl}>
          <InputLabel id="field_type" />
          <Select
            labelId="field_type"
            id="field_type_select"
            value={fieldType}
            onChange={(event) => setFieldType(event.target.value)}
            MenuProps={{
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
          </Select>
        </FormControl>
      </Grid>

      <Grid item>
        <Typography className={classes.fieldName}>
          Required?
        </Typography>
        <FormControlLabel
          control={(
            <Checkbox
              value={isRequired}
              onChange={(event) => setIsRequired(event.target.value)}
              name="required"
              color="primary"
            />
          )}
          label="Required"
        />
      </Grid>

      <Grid item>
        <Typography className={classes.fieldName}>
          Array?
        </Typography>
        <FormControlLabel
          control={(
            <Checkbox
              value={isArray}
              onChange={(event) => setIsArray(event.target.value)}
              name="array"
              color="primary"
            />
          )}
          label="Array"
        />
      </Grid>

      <Grid item>
        <Typography className={classes.fieldName}>
          Sample Options (If type=&lsquo;sample&lsquo;)
        </Typography>
      </Grid>

      <Grid item>
        <Typography className={classes.fieldName}>
          Choices (Comma separated. Leave blank for unrestricted value).
        </Typography>
      </Grid>
    </Grid>
  );
};

export default SampleTypeField;
