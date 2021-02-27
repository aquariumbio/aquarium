import React from 'react';
import PropTypes from 'prop-types';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import AllowableFieldTypeSelect from './AllowableFieldTypeSelect';
import { StandardButton } from '../../shared/Buttons';

const SampleOptionsInput = ({
  handleAddClick,
  handleChange,
  showSampleSelect,
  sampleTypes,
  fieldType,
  index,
}) => (
  <Grid item lg={2} data-cy="samples-div">
    {showSampleSelect() ? (
      <> {sampleTypes.length > 0 ? (
        <>
          <AllowableFieldTypeSelect
            sampleTypes={sampleTypes}
            handleChange={handleChange}
            fieldType={fieldType}
            fieldTypeIndex={index}
          />
          <div style={{ display: 'block' }}>
            <StandardButton
              name="add-field-option-btn"
              variant="outlined"
              testName="add-field-option-btn"
              handleClick={() => handleAddClick(index)}
              text="Add option"
            />
          </div>
        </>
      ) : (
        <Typography>No sample types</Typography>
      )} </>
    ) : (
      <Typography data-testid="NA-samples">N/A</Typography>
    )}
  </Grid>
);
SampleOptionsInput.propTypes = {
  handleChange: PropTypes.func.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  // allowableFieldTypes: PropTypes.array.isRequired,
  showSampleSelect: PropTypes.func.isRequired,
  handleAddClick: PropTypes.func.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  sampleTypes: PropTypes.array.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  fieldType: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
};

export default SampleOptionsInput;
