import React, { useState } from 'react';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';

const SampleTypeForm = () => {
  const [sampleTypeName, setSampleTypeName] = useState('');

  const handleSubmit = (event) => {
    event.preventDefault();
    // TODO: COMPLETE SUBMIT FUNCTION & REMOVE ALERT PLACE HOLDER
    // eslint-disable-next-line no-alert
    alert('Form sumbitted');
  };

  return (
    <>
      <Typography variant="h1" align="center">
        Defining New Sample Type
      </Typography>

      <Typography variant="h4">Name</Typography>
      <form name="sampe_type_definition_form" onSubmit={handleSubmit}>
        <TextField
          name="sample_type_name"
          value={sampleTypeName}
          id="sample_type_name"
          label="sample type name"
          defaultValue="New sample type"
          onChange={(event) => setSampleTypeName(event.target.value)}
          variant="outlined"
          required
          helperText="Sample name is required."
        />
      </form>
    </>
  );
};

export default SampleTypeForm;
