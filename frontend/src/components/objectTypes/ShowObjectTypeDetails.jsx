import React, { useState, useEffect } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';

const useStyles = makeStyles((theme) => ({
  pointer: {
    cursor: 'pointer',
  },
}));

// eslint-disable-next-line no-unused-vars
const ShowObjectTypeDetails = ({ objectType }) => {
  const classes = useStyles();

  return (
    <>
      <p>
        <b>Location</b>:&nbsp;
        {objectType.wizard_id ? (
          <b><Link component={RouterLink} to={`/wizards/${objectType.wizard_id}/show/`}>{objectType.prefix}</Link></b>
        ) : (
          <i>Not specified</i>
        )}
      </p>
      <p>
        <b>Sample Type</b>:&nbsp;
        {objectType.sample_type ? (
          <b><Link className={classes.pointer} onClick={() => alert('sample type page')}>{objectType.sample_type}</Link></b>
        ) : (
          <i>Not specified</i>
        )}
      </p>
      <p>
        <b>Min/Max</b>: {objectType.min} / {objectType.max}
      </p>
      <p>
        <b>Unit/Cost</b>: {objectType.unit} / {objectType.cost}
      </p>
      <p>
        <b>Handler</b>: {objectType.handler}
      </p>
      <p>
        <b>Release</b>: {objectType.release_method}
      </p>
      <p>
        <b>Safety</b>: {objectType.safety}
      </p>
      <p>
        <b>Cleanup</b>: {objectType.cleanup}
      </p>
      <p>
        <b>Data</b>: {objectType.data}
      </p>
      <p>
        <b>Vendor</b>: {objectType.vendor}
      </p>
    </>
  );
};

ShowObjectTypeDetails.propTypes = {
  objectType: PropTypes.isRequired,
};

export default ShowObjectTypeDetails;
