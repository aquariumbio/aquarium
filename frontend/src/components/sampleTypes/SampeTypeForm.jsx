import { makeStyles } from '@material-ui/core';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import Typography from '@material-ui/core/Typography';
import React, { useState } from 'react';

const useStyles = makeStyles(() => ({
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
    margin: '10px 0',
  },
}));

const SampleTypeForm = () => {
  const classes = useStyles();
  const [sampleTypeName, setSampleTypeName] = useState('');
  const [sampleTypeDescription, setSampleTypeDescription] = useState('');

  const handleSubmit = (event) => {
    event.preventDefault();
    // TODO: COMPLETE SUBMIT FUNCTION & REMOVE ALERT PLACE HOLDER
    // eslint-disable-next-line no-alert
    alert('Form sumbitted');
  };

  return (
    <Container maxWidth="xl" minWidth>
      <Typography variant="h1" align="center" className={classes.title}>
        Defining New Sample Type
      </Typography>

      <form name="sampe_type_definition_form" onSubmit={handleSubmit}>
        <Typography variant="h4" className={classes.inputName}>
          Name
        </Typography>
        <TextField
          name="sample_type_name"
          fullWidth
          value={sampleTypeName}
          id="sample_type_name"
          label="sample type name"
          defaultValue="New sample type"
          onChange={(event) => setSampleTypeName(event.target.value)}
          variant="outlined"
          required
          // TODO: Error HANDLING -- ONLY SHOW HELPER TEXT ON ERROR
          helperText="Sample name is required."
        />

        <Typography variant="h4" className={classes.inputName}>
          Description
        </Typography>
        <TextField
          name="sample_type_description"
          fullWidth
          value={sampleTypeDescription}
          id="sample_type_description"
          label="sample type description"
          defaultValue="New sample type description"
          onChange={(event) => setSampleTypeDescription(event.target.value)}
          variant="outlined"
          required
          // TODO: Error HANDLING -- ONLY SHOW HELPER TEXT ON ERROR
          helperText="Sample type description is required."
        />
      </form>
    </Container>
  );
};

export default SampleTypeForm;
