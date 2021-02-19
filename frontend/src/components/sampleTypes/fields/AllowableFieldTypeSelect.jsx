import React from 'react';
import PropTypes from 'prop-types';
import Select from '@material-ui/core/Select';
import MenuItem from '@material-ui/core/MenuItem';
import utils from '../../../helpers/utils';

const AllowableFieldTypeSelect = ({
  sampleTypes, handleChange, fieldTypeIndex, fieldType,
}) => (
  <>
    {!!fieldType.allowable_field_types
        && fieldType.allowable_field_types.map((aft, index) => (
          <div style={{ display: 'block' }} key={utils.randString()}>
            <Select
              style={{ width: 250 }}
              name={`allowableFieldType[${fieldTypeIndex}]`}
              labelId="allowable-field-type-select-label"
              variant="outlined"
              id={`allowable-field-type-select[${index}]`}
              value={aft.name}
              onChange={handleChange}
              displayEmpty
              defaultValue=""
              inputProps={{ 'aria-label': 'allowable-field-type-select-label' }}
              MenuProps={{
                // open below
                anchorOrigin: {
                  vertical: 'bottom',
                  horizontal: 'left',
                },
                getContentAnchorEl: null,
              }}
              data-cy="allowable-field-type-select-label"
            >
              <MenuItem value="" name="select-none" disabled>
                {' Choose one '}
              </MenuItem>
              {sampleTypes.map((st) => (
                <MenuItem
                  key={st.id}
                  value={st.name}
                  name={`select-${st.name}`}
                >
                  {st.name}
                </MenuItem>
              ))}
            </Select>
          </div>
        ))}
  </>
);
AllowableFieldTypeSelect.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  sampleTypes: PropTypes.array.isRequired,
  handleChange: PropTypes.func.isRequired,
  fieldTypeIndex: PropTypes.number.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  fieldType: PropTypes.object.isRequired,
};

export default AllowableFieldTypeSelect;
