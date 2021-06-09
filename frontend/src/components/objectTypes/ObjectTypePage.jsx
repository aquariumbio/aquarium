import React, { useState, useEffect } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import ListItem from '@material-ui/core/ListItem';
import Grid from '@material-ui/core/Grid';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import Link from '@material-ui/core/Link';
import Alert from '@material-ui/lab/Alert';

import ShowObjectTypeDetails from './ShowObjectTypeDetails';
import { StandardButton, LinkButton } from '../shared/Buttons';
import objectsAPI from '../../helpers/api/objectsAPI';

// Route: /object_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles(() => ({
  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  borderLeft: {
    borderLeft: '1px solid #ccc',
  },

  wrapper: {
    padding: '0 24px',
  },

  pointer: {
    cursor: 'pointer',
  },
}));

// eslint-disable-next-line no-unused-vars
const ObjectTypePage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();

  const id = match.params.id;
  const [objectType, setObjectType] = useState([]);

  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await objectsAPI.getById(id);
      if (!response) return;

      // success
      setObjectType(response.object_type);
    };

    init();
  }, []);

  return (
    <>
      {/* SIDEBAR */}
      <Grid container className={classes.root}>
        <Grid
          item
          xs={2}
          name="object-types-side-bar"
          data-cy="object-types-side-bar"
          className={classes.root}
        >
        </Grid>

        {/* MAIN CONTENT */}
        <Grid  className={classes.borderLeft}
          item
          xs={10}
          name="object-types-main-container"
          data-cy="object-types-main-container"
          overflow="visible"
        >
          <Toolbar className={classes.header}>
            <Breadcrumbs
              separator={<NavigateNextIcon fontSize="small" />}
              aria-label="breadcrumb"
              component="div"
              data-cy="page-title"
            >
              <Typography display="inline" variant="h6" component="h1">
                Object Type Handlers
              </Typography>
              <Typography display="inline" variant="h6" component="h1">
                {objectType ? objectType.handler : '' }
              </Typography>
              <Typography display="inline" variant="h6" component="h1">
                {objectType ? objectType.name : '' }
              </Typography>
            </Breadcrumbs>

            <div>
              <LinkButton
                name="Edit Object Type"
                testName="edit_object_type_btn"
                text="Edit"
                type="button"
                linkTo={`/object_types/${id}/edit`}
              />
            </div>
          </Toolbar>

          <Divider />

          {objectType ? (
            <Typography className={classes.wrapper}>
              <p>
                <b>Description</b>: {objectType.description}
              </p>
              <ShowObjectTypeDetails objectType={objectType} />
            </Typography>
          ) : (
            ''
          )}
        </Grid>
      </Grid>
    </>
  );
};

ObjectTypePage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default ObjectTypePage;
