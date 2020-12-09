import React from 'react';
import Typography from '@material-ui/core/Typography';
import PropTypes from 'prop-types';
import List from '@material-ui/core/List';
import Link from '@material-ui/core/Link';
import { Link as RouterLink } from 'react-router-dom';
import { makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  list: {
    listStyleType: 'disc',
    marginLeft: theme.spacing(3),
    marginBottom: theme.spacing(1),
  },
}));

// Display allowable field types (samples)
const AftList = ({ allowableFieldTypes }) => allowableFieldTypes
  .map((aft) => (
    /* Use component prop on material ui Link to integrate with react router dom */
    <Link key={aft.id} component={RouterLink} to={`/sample_types/${aft.id}`}>
      {aft.name}
    </Link>
  ))
  .reduce((prev, curr) => [prev, ' | ', curr]);

// Given an array of field types display as a list
const FieldTypesList = ({ fieldTypes }) => {
  const classes = useStyles();

  return (
    <List component="ul" className={classes.list}>
      {fieldTypes.map((field) => (
        <li key={field.id}>
          <b>{field.name}</b>
          {': '}
          {field.ftype === 'sample' && field.allowable_field_types ? (
            <AftList allowableFieldTypes={field.allowable_field_types} />
          ) : (
            field.ftype
          )}
          {field.choices && <Typography display="inline">: [ {field.choices} ]</Typography>}
        </li>
      ))}
    </List>
  );
};

export default FieldTypesList;

FieldTypesList.propTypes = {
  fieldTypes: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      ftype: PropTypes.oneOf(['string', 'number', 'sample', 'url']),
      required: PropTypes.bool,
      array: PropTypes.bool,
      choices: PropTypes.string,
      allowable_field_types: PropTypes.arrayOf(
        PropTypes.shape({
          id: PropTypes.number,
          field_type_id: PropTypes.number,
          sample_type_id: PropTypes.number,
          name: PropTypes.string,
        }),
      ),
    }),
  ).isRequired,
};
