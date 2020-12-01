import { makeStyles } from '@material-ui/core';
import Button from '@material-ui/core/Button';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import React, { useState } from 'react';
import Grid from '@material-ui/core/Grid';
import { FieldLabels, SampleTypeField } from './SampleTypeFieldForm';

const useStyles = makeStyles((theme) => ({
  container: {
    minWidth: 'lg',
  },
  title: {
    fontSize: '2.5rem',
    fontWeight: '700',
    marginTop: '12px',
    marginBottom: '30px',
  },
  inputName: {
    fontSize: '1rem',
    fontWeight: '700',
  },
  lightBtn: {
    backgroundColor: 'rgb(250, 250, 250)',
    color: '#065683',
    margin: theme.spacing(3, 2),

    '& :hover': {
      backgroundColor: '#065683',
      color: 'rgb(250, 250, 250)',
    },
  },
}));

const SampleTypeDefinitionForm = (sampleType) => {
  const classes = useStyles();
  const [sampleTypeName, setSampleTypeName] = useState(sampleType.name || '');
  const [sampleTypeDescription, setSampleTypeDescription] = useState(sampleType.description || '');
  const [fieldTypes, setFieldTypes] = useState(
    sampleType.fieldTypes || [
      {
        id: null,
        name: '',
        type: '',
        isRequired: false,
        isArray: false,
        choices: '',
      },
    ],
  );

  // Submit form with all data
  const handleSubmit = (event) => {
    event.preventDefault();
    // TODO: COMPLETE SUBMIT FUNCTION & REMOVE ALERT PLACE HOLDER
    // eslint-disable-next-line no-alert
    alert('Form sumbitted');
  };

  // Handle click add field button --> add new field type to end of current field types array
  const handleAddFieldClick = () => {
    const newFieldType = {
      id: null,
      name: '',
      type: '',
      isRequired: false,
      isArray: false,
      choices: '',
    };
    setFieldTypes([...fieldTypes, newFieldType]);
  };

  // handle click event of the Remove button
  const handleRemoveFieldClick = (index) => {
    const list = [...fieldTypes];
    list.splice(index, 1);
    setFieldTypes(list);
  };

  // handle field type input change
  const handleFieldInputChange = (name, value, index) => {
    const list = [...fieldTypes];
    list[index][name] = value;
    setFieldTypes(list);
  };

  // create array of field components
  const fieldTypeList = fieldTypes.map(
    (fieldType, index) => (
      <SampleTypeField
        // eslint-disable-next-line react/no-array-index-key
        key={`${fieldType.id}_${index}`}
        fieldType={fieldType}
        index={index}
        updateParentState={handleFieldInputChange}
        handleRemoveFieldClick={() => handleRemoveFieldClick}
      />
    ),
  );

  return (
    <Container maxWidth="xl" cy-data="field_form_container">
      <Typography variant="h1" align="center" className={classes.title}>
        Defining New Sample Type
      </Typography>

      <Typography align="right">* field is required</Typography>

      <form name="sampe_type_definition_form" onSubmit={handleSubmit}>
        <Typography variant="h4" className={classes.inputName} display="inline">
          Name
        </Typography>
        <Typography variant="overline" color="error" display="inline">
          {' '}
          *
          {' '}
        </Typography>

        <TextField
          name="sample_type_name_input"
          fullWidth
          value={sampleTypeName}
          id="sample_type_name_input"
          onChange={(event) => setSampleTypeName(event.target.value)}
          variant="outlined"
          autoFocus
          required
          type="string"
          // TODO: Error HANDLING -- ONLY SHOW HELPER TEXT ON ERROR
        />

        <Typography variant="h4" className={classes.inputName} display="inline">
          Description
        </Typography>
        <Typography variant="overline" color="error">
          {' '}
          *
          {' '}
        </Typography>

        <TextField
          name="sample_type_description_input"
          fullWidth
          value={sampleTypeDescription}
          id="sample_type_description_input"
          onChange={(event) => setSampleTypeDescription(event.target.value)}
          variant="outlined"
          type="string"
          required
          // TODO: Error HANDLING -- ONLY SHOW HELPER TEXT ON ERROR
        />

        <Grid
          container
          spacing={1}
          style={{ marginTop: '1rem' }}
          cy-data="field_form_container"
        >
          <FieldLabels />
          {fieldTypeList}
        </Grid>

        <Button
          name="add_new_field"
          data-cy="add_new_field"
          className={classes.lightBtn}
          size="small"
          onClick={handleAddFieldClick}
        >
          Add New Field
        </Button>
      </form>
    </Container>
  );
};

export default SampleTypeDefinitionForm;
