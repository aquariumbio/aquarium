/* eslint-disable react/no-array-index-key */
import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import React, { useState, useEffect } from 'react';
import Grid from '@material-ui/core/Grid';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import API from '../../helpers/API';
import SideBar from './SideBar';
import LoadingBackdrop from '../shared/LoadingBackdrop';
import ShowSampleType from './ShowSampleType';
import { LinkButton, StandardButton } from '../shared/Buttons';

// Route: /sample_types
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

const SampleTypeDefinitions = () => {
  const classes = useStyles();

  const [sampleTypes, setSampleTypes] = useState([]);
  const [currentSampleType, setCurrentSampleType] = useState({});
  const [isLoading, setIsLoading] = useState(true);

  /*  Get sample types top populate sample options menu
      We cannot use async directly in useEffect so we create an async function that we will call
      from w/in useEffect.
      Our async function gets and sets the sampleTypes.
      We only want to fetch data when the component is mounted so we pass an empty array as the
      second argument to useEffect  */
  useEffect(() => {
    const fetchData = async () => {
      const data = await API.samples.getTypes();
      setSampleTypes(data.sample_types);
      setCurrentSampleType(data.first);
      setIsLoading(false);
    };

    fetchData();
  }, []);

  const handleDelete = async () => {
    await API.samples.delete(currentSampleType.id);
    window.location.reload();
  };

  return (
    <>
      <LoadingBackdrop isLoading={isLoading} />
      {!isLoading && (
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
                  {currentSampleType.name}
                </Typography>
              </Breadcrumbs>
              <div>
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

            <ShowSampleType sampleType={currentSampleType} />
          </Grid>
        </Grid>
      )}
    </>
  );
};
export default SampleTypeDefinitions;
