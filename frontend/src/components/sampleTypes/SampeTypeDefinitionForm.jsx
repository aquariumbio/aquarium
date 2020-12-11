import { makeStyles } from '@material-ui/core';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import React, { useState, useEffect } from 'react';
import Grid from '@material-ui/core/Grid';
import { FieldLabels, SampleTypeField } from './SampleTypeFieldForm';
import API from '../../helpers/API';
import LoadingBackdrop from '../shared/LoadingBackdrop';
import { StandardButton } from '../shared/Buttons';

const useStyles = makeStyles(() => ({
  container: {
    minWidth: 'lg',
    overflow: 'auto',
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
}));

const SampleTypeDefinitionForm = (sampleType) => {
  const classes = useStyles();
  const [sampleTypeName, setSampleTypeName] = useState(sampleType.name || '');
  const [sampleTypeDescription, setSampleTypeDescription] = useState(
    sampleType.description || '',
  );
  const [fieldTypes, setFieldTypes] = useState(
    sampleType.fieldTypes || [
      {
        id: null,
        name: '',
        type: '',
        isRequired: false,
        isArray: false,
        choices: '',
        allowableFieldTypes: [],
      },
    ],
  );
  const [sampleTypes, setSampleTypes] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  //  Get sample types top populate sample options menu
  useEffect(() => {
    //  We cannot use async directly in useEffect
    //  so we create an async function that we will call from w/in
    const fetchData = async () => {
      const data = await API.samples.getTypes();
      //  Update state with response from API
      setSampleTypes(data.sample_types);
      setIsLoading(false);
    };

    fetchData();
    //  We only want to fetch data when the component is mounted
    //  so we pass an empty array as the second argument to useEffect
  }, []);

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
      allowable_field_types: [],
    };
    setFieldTypes([...fieldTypes, newFieldType]);
  };

  // eslint-disable-next-line no-console
  console.log(JSON.stringify(sampleTypeName));

  // eslint-disable-next-line no-console
  console.log(sampleTypeName);

  // Handle click add new sample to the end of the allowable fields array
  const handleAddAllowableFieldClick = (index) => {
    const list = [...fieldTypes];
    if (list[index].allowable_field_types === undefined) {
      list[index].allowable_field_types = [];
    }
    list[index].allowable_field_types.push({});
    setFieldTypes(list);
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
  const fieldTypeList = fieldTypes.map((fieldType, index) => (
    <SampleTypeField
      // eslint-disable-next-line react/no-array-index-key
      key={`${fieldType.id}_${index}`}
      fieldType={fieldType}
      sampleTypes={sampleTypes}
      index={index}
      updateParentState={handleFieldInputChange}
      handleRemoveFieldClick={() => handleRemoveFieldClick}
      handleAddAllowableFieldClick={() => handleAddAllowableFieldClick}
    />
  ));

  return (
    <Container maxWidth="xl" cy-data="field_form_container">
      <LoadingBackdrop isLoading={isLoading} />
      <Typography variant="h1" align="center" className={classes.title}>
        Defining New Sample Type
      </Typography>

      <Typography align="right">* field is required</Typography>

      <form name="sampe_type_definition_form" onSubmit={handleSubmit}>
        <Typography variant="h4" className={classes.inputName} display="inline">
          Name
        </Typography>
        <Typography variant="overline" color="error">
          {' * '}
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
          {' * '}
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

        {!!fieldTypeList.length && (
          <Grid
            container
            spacing={1}
            style={{ marginTop: '1rem' }}
            cy-data="field_form_container"
          >
            <FieldLabels />

            {fieldTypeList}
          </Grid>
        )}

        <StandardButton
          name="add_new_field"
          testName="add_new_field"
          handleClick={handleAddFieldClick}
          text="Add New Field"
        />
      </form>
    </Container>
  );
};

export default SampleTypeDefinitionForm;
