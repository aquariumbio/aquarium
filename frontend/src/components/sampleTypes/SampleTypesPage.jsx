/* eslint-disable react/no-array-index-key */
import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import React, { useState, useEffect } from 'react';
import Grid from '@material-ui/core/Grid';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import samplesAPI from '../../helpers/api/samples';
import SideBar from './SideBar';
import LoadingBackdrop from '../shared/LoadingBackdrop';
import ShowSampleType from './ShowSampleType';
import { LinkButton, StandardButton } from '../shared/Buttons';
import AlertToast from '../shared/AlertToast';

// Route: /sample_types
// Linked in LeftHamburgeMenu
const useStyles = makeStyles(() => ({
  root: {
    height: '90vh',
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
}));

const SampleTypeDefinitions = () => {
  const classes = useStyles();

  const [sampleTypes, setSampleTypes] = useState([]);
  const [currentSampleType, setCurrentSampleType] = useState({});
  const [isLoading, setIsLoading] = useState(true);
  const [alertProps, setAlertProps] = useState({
    message: '',
    severity: 'info',
    open: false,
  });

  /*  Get sample types top populate sample options menu
      We cannot use async directly in useEffect so we create an async function that we will call
      from w/in useEffect.
      Our async function gets and sets the sampleTypes.
      We only want to fetch data when the component is mounted so we pass an empty array as the
      second argument to useEffect  */
  useEffect(() => {
    const fetchData = async () => {
      const responseData = await samplesAPI.getTypes();

      if (responseData) {
        setSampleTypes(responseData.sample_types);
        setCurrentSampleType(responseData.first);
      }

      if (!responseData) {
        setAlertProps({ severity: 'error', message: 'Error fetching data' });
      }

      return setIsLoading(false);
    };

    fetchData();
  }, []);

  const handleDelete = async () => {
    const response = await samplesAPI.delete(currentSampleType.id);

    /*  When we successfully delete a sample type we set the success alert,
        make a new call to get all sample types and update the current sample type
        so the user is seeing valid data */
    if (response.status === 200) {
      const data = await samplesAPI.getTypes();

      setAlertProps({
        message: `${currentSampleType.name} deleted`,
        severity: 'success',
        open: true,
      });

      setSampleTypes(data.sample_types);
      setCurrentSampleType(data.first);
      return true;
    }

    /*  Failure alert  */
    return setAlertProps({
      message: `${currentSampleType.name} could not be deleted`,
      severity: 'error',
      open: true,
    });
  };

  return (
    <>
      <LoadingBackdrop isLoading={isLoading} />
      <AlertToast
        open={alertProps.open}
        severity={alertProps.severity}
        message={alertProps.message}
      />

      {!isLoading && sampleTypes && (
        <Grid container className={classes.root}>
          {/* SIDE BAR */}
          <SideBar
            setCurrentSampleType={setCurrentSampleType}
            sampleTypes={sampleTypes}
          />

          {/* MAIN CONTENT */}
          <Grid item xs={10} name="sample-types-main-container" data-cy="sample-types-main-container" overflow="visible">

            <Toolbar className={classes.header}>
              <Breadcrumbs
                separator={<NavigateNextIcon fontSize="small" />}
                aria-label="breadcrumb"
                component="div"
                data-cy="page-title"
              >
                <Typography display="inline" variant="h6" component="h1">
                  Sample Type Defnitions
                </Typography>
                <Typography display="inline" variant="h6" component="h1">
                  {currentSampleType ? currentSampleType.name : ''}
                </Typography>
              </Breadcrumbs>
              <div>
                {currentSampleType
                  ? (
                    <>
                      <LinkButton
                        name="Edit Sample Type"
                        testName="edit_sample_type_btn"
                        text="Edit"
                        type="button"
                        linkTo={`/sample_types/${currentSampleType.id}/edit`}
                      />

                      <StandardButton
                        name="Delete Sample Type"
                        testName="delete_sample_type_btn"
                        text="Delete"
                        type="button"
                        handleClick={handleDelete}
                      />
                    </>
                  )
                  : ''}
                <LinkButton
                  name="New Sample Type"
                  testName="new_sample_type_btn"
                  text="New"
                  dark
                  type="button"
                  linkTo="/sample_types/new"
                />
              </div>
            </Toolbar>

            <Divider />

            {currentSampleType.id && (
              <ShowSampleType sampleType={currentSampleType} />
            )}

            {!sampleTypes.length && (
              <Typography variant="h6" component="h1">
                No Sample Type Defnitions
              </Typography>
            )}

          </Grid>
        </Grid>
      )}
    </>
  );
};
export default SampleTypeDefinitions;
