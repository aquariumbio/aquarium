import React from 'react';
import PropTypes from 'prop-types';
import List from '@material-ui/core/List';

import Link from '@material-ui/core/Link';
import { Link as RouterLink } from 'react-router-dom';
import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import { LinkButton } from '../shared/Buttons';

const useStyles = makeStyles((theme) => ({
  subheader: {
    fontSize: '1.25rem',
  },
  list: {
    listStyleType: 'disc',
    marginLeft: theme.spacing(3),
    marginBottom: theme.spacing(1),
  },
}));

const ObjectTypesList = ({ objectTypes, sampleTypeId }) => {
  const classes = useStyles();
  return (
    <>
      <Typography variant="h6" component="h2">
        Object Categories
      </Typography>
      <List
        aria-labelledby="object_types_list"
        component="ul"
        className={classes.list}
      >
        {objectTypes.length ? (
          objectTypes.map((object) => (
            <li key={object.id}>
              <Link component={RouterLink} to={`/object_types/${object.id}`}>
                <b>{object.name}</b>
              </Link>
              : {object.description}
            </li>
          ))
        ) : (
          <li>No object categories.</li>
        )}
        <LinkButton
          name="add_object_type"
          testName="add_object_type"
          text="Add"
          linkTo={`/object_types/new?sample_type_id=${sampleTypeId}`}
        />
      </List>
    </>
  );
};

export default ObjectTypesList;

ObjectTypesList.propTypes = {
  objectTypes: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      description: PropTypes.string,
      min: PropTypes.number,
      max: PropTypes.number,
      handler: PropTypes.string,
      safety: PropTypes.string,
      cleanup: PropTypes.string,
      data: PropTypes.string,
      vendor: PropTypes.string,
      created_at: PropTypes.string,
      updated_at: PropTypes.string,
      unit: PropTypes.string,
      cost: PropTypes.number,
      release_method: PropTypes.string,
      release_description: PropTypes.string,
      sample_type_id: PropTypes.number,
      image: PropTypes.string,
      prefix: PropTypes.string,
      rows: PropTypes.number,
      columns: PropTypes.number,
    }),
  ).isRequired,
  sampleTypeId: PropTypes.number.isRequired,
};
