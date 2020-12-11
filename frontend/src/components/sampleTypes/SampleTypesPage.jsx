/* eslint-disable react/no-array-index-key */
import { makeStyles } from '@material-ui/core';
import Paper from '@material-ui/core/Paper';
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
import { LinkButton } from '../shared/Buttons';

// Route: /sample_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles(() => ({
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

  useEffect(() => {
    const fetchData = async () => {
      const data = await API.samples.getTypes();
      setSampleTypes(data.sample_types);
      setCurrentSampleType(data.first);
      setIsLoading(false);
    };

    fetchData();
  }, []);

  const pageRef = React.useRef();
  return (
    <>
      <LoadingBackdrop isLoading={isLoading} />
      <Paper elevation={3} ref={pageRef}>
        {!isLoading && (
          <Grid container>
            {/* SIDE BAR */}
            <Grid item lg={2} name="left_side_bar">
              <SideBar
                setCurrentSampleType={setCurrentSampleType}
                sampleTypes={sampleTypes}
              />
            </Grid>

            {/* MAIN CONTENT */}
            <Grid item lg={10} name="right_main_container">
              <Toolbar className={classes.header}>
                <Breadcrumbs
                  separator={<NavigateNextIcon fontSize="small" />}
                  aria-label="breadcrumb"
                  component="div"
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

                  <LinkButton
                    name="Delete Sample Type"
                    testName="delete_sample_type_btn"
                    text="Delete"
                    type="button"
                    linkTo={`/sample_types/${currentSampleType.id}/delete`}
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
      </Paper>
    </>
  );
};
export default SampleTypeDefinitions;
