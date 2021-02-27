import React from 'react';
import PropTypes from 'prop-types';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';
import Grid from '@material-ui/core/Grid';

const RemoveFieldBtn = ({ handleRemoveFieldClick, index }) => (
  <Grid item lg={1} data-cy="remove-field-btn-div">
    <IconButton
      onClick={handleRemoveFieldClick(index)}
      data-cy="remove-field-btn"
      aria-label="remove-field"
    >
      <CloseIcon />
    </IconButton>
  </Grid>
);
RemoveFieldBtn.propTypes = {
  handleRemoveFieldClick: PropTypes.func.isRequired,
  index: PropTypes.number.isRequired,
};

export default RemoveFieldBtn;
