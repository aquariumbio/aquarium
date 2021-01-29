/* eslint-disable react/no-array-index-key */
import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import React, { useState, useEffect } from 'react';
import Grid from '@material-ui/core/Grid';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import objectsAPI from '../../helpers/api/objects';
import SideBar from './SideBar';
import LoadingBackdrop from '../shared/LoadingBackdrop';
import ShowObjectTypesByHandler from './ShowObjectTypesByHandler';
import { LinkButton, StandardButton } from '../shared/Buttons';

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

  /*  Get object types top populate object options menu
      We cannot use async directly in useEffect so we create an async function that we will call
      from w/in useEffect.
      Our async function gets and sets the objectTypes.
      We only want to fetch data when the component is mounted so we pass an empty array as the
      second argument to useEffect  */
  useEffect(() => {
    const fetchData = async () => {
      // loading overlay - delay by 300ms to avoid screen flash
      let loading = setTimeout(() => { setIsLoading( true ) }, window.$timeout);

      const response = await objectsAPI.getHandlers();

      // break if the HTTP call resulted in an error ("return false" from API.js)
      // NOTE: the alert("break") is just there for testing. Whatever processing should be handled in API.js, and we just need stop the system from trying to continue...
      if (!response) {
        alert("break")
        return;
      }

      // clear timeout and clear overlay
      clearTimeout(loading);
      setIsLoading(false);

      // success
      if ( response.handlers ) {
        let first = response.handlers[0]

        setObjectTypeHandlers(response.handlers);
        setCurrentObjectTypeHandler(first.handler);
        setCurrentObjectTypesByHandler(response[first.handler]["object_types"])
      }

      // show alert popup if passed in sessionStorage
      if (sessionStorage.alert) {
        setAlertProps(JSON.parse(sessionStorage.alert))
        sessionStorage.removeItem("alert")
      }
    };

    fetchData();
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
