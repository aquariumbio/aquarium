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
  name: {
    fontSize: '1rem',
    fontWeight: '700',
    margin: '10px 0',
  },
  input: {

  },
}));

const SampleTypeForm = () => {
  const classes = useStyles();
  const [sampleTypeName, setSampleTypeName] = useState('');

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

      <Typography variant="h4" className={classes.name}>
        Name
      </Typography>
      <form name="sampe_type_definition_form" onSubmit={handleSubmit}>
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
      </form>
    </Container>
  );
};

export default SampleTypeForm;
