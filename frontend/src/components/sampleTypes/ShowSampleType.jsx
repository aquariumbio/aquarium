import React from 'react';
import PropTypes from 'prop-types';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import Pluralize from 'pluralize';
import Link from '@material-ui/core/Link';
import { Link as RouterLink } from 'react-router-dom';
import ObjectTypesList from './ObjectTypesList';
import FieldTypesList from './FieldTypesList';

const useStyles = makeStyles((theme) => ({
  inventory: {
    fontSize: '0.875rem',
    marginBottom: theme.spacing(2),
  },
}));

const ShowSampleType = ({ sampleType }) => {
  const classes = useStyles();

  return (
    <Card name="sample_type_definition_card">
      <CardContent>
        <Typography variant="h6" component="h2">
          {sampleType.description}
        </Typography>

        {sampleType.field_types && (
          <FieldTypesList fieldTypes={sampleType.field_types} />
        )}

        <Typography variant="body1" className={classes.inventory}>
          There are {sampleType.inventory}{' '}
          <Link component={RouterLink} to={`/browser?stid=${sampleType.id}`}>
            {Pluralize(sampleType.name, sampleType.inventory)}
          </Link>{' '}
          in the inventory
        </Typography>

        <ObjectTypesList
          sampleTypeId={sampleType.id}
          objectTypes={sampleType.object_types}
        />
      </CardContent>
    </Card>
  );
};

export default ShowSampleType;

ShowSampleType.propTypes = {
  sampleType: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    description: PropTypes.string,
    object_types: PropTypes.arrayOf(
      PropTypes.shape({
        allowable_field_types: PropTypes.arrayOf(
          PropTypes.shape({
            id: PropTypes.number,
            field_type_id: PropTypes.number,
            sample_type_id: PropTypes.number,
            name: PropTypes.string,
          }),
        ),
        array: PropTypes.bool,
        choices: PropTypes.string,
        created_at: PropTypes.string,
        ftype: PropTypes.string,
        id: PropTypes.number,
        name: PropTypes.string,
        parent_class: PropTypes.string,
        parent_id: PropTypes.number,
        part: null,
        preferred_field_type_id: null,
        preferred_operation_type_id: null,
        required: PropTypes.bool,
        role: null,
        routing: null,
        updated_at: PropTypes.string,
      }),
    ),
    inventory: PropTypes.number,
    field_types: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      type: PropTypes.string,
      isRequired: PropTypes.bool,
      isArray: PropTypes.bool,
      choices: PropTypes.string,
    })),
  }).isRequired,
};
