/* eslint-disable react/no-array-index-key */
import React, { useState, useEffect } from 'react';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Grid from '@material-ui/core/Grid';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';

import SideBar from './SideBar';
import LoadingBackdrop from '../shared/LoadingBackdrop';
import ShowObjectTypesByHandler from './ShowObjectTypesByHandler';
import { LinkButton, StandardButton } from '../shared/Buttons';
import objectsAPI from '../../helpers/api/objects';

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
}));

const ObjectTypesPage = ({setIsLoading, setAlertProps}) => {
  const classes = useStyles();

  const [objectTypeHandlers, setObjectTypeHandlers] = useState([]);
  const [currentObjectTypeHandler, setCurrentObjectTypeHandler] = useState([]);
  const [currentObjectTypesByHandler, setCurrentObjectTypesByHandler] = useState([]);

  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await objectsAPI.getHandlers();
      if (!response) return;

      // success
      if (response.handlers) {
        let first = response.handlers[0];
        setObjectTypeHandlers(response.handlers);
        setCurrentObjectTypeHandler(first.handler);
        setCurrentObjectTypesByHandler(response[first.handler]['object_types']);
      }
    };

    init();
  }, []);

  return (
    <>
        <Grid container className={classes.root}>
          {/* SIDE BAR */}
          <SideBar
            objectTypeHandlers={objectTypeHandlers}
            setCurrentObjectTypeHandler={setCurrentObjectTypeHandler}
            setCurrentObjectTypesByHandler={setCurrentObjectTypesByHandler}
            setIsLoading={setIsLoading}
            setAlertProps={setAlertProps}
          />

          {/* MAIN CONTENT */}
          <Grid item xs={10} name="object-types-main-container" data-cy="object-types-main-container" overflow="visible">
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
                  {currentObjectTypeHandler}
                </Typography>
              </Breadcrumbs>

              <div>
                <LinkButton
                  name="New Object Type"
                  testName="new_object_type_btn"
                  text="New"
                  dark
                  type="button"
                  linkTo="/object_types/new"
                />
              </div>
            </Toolbar>

            <Divider />

            {currentObjectTypesByHandler
              ? <ShowObjectTypesByHandler objectTypes={currentObjectTypesByHandler} setIsLoading={setIsLoading} setAlertProps={setAlertProps} />
              : ''}
          </Grid>
        </Grid>
    </>
  );
};

export default ObjectTypesPage;
