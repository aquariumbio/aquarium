import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import Grid from '@material-ui/core/Grid';

import SideBar from './SideBar';
import { LinkButton } from '../shared/Buttons';
import wizardsAPI from '../../helpers/api/wizards';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  wrapper: {
    padding: '0 24px',
  },

  letter: {
    color: theme.palette.primary.main,
  },

  /* flex */
  flexWrapper: {
    padding: '0 16px',
  },

  flex: {
    display: '-ms-flexbox',
    // eslint-disable-next-line no-dupe-keys
    display: 'flex',
    position: 'relative',
  },

  /* Title row */
  flexTitle: {
    padding: '8px 0',
    borderBottom: '2px solid #c0c0c0',
  },

  /* Data Row */
  flexRow: {
    padding: '8px 0',
    borderBottom: '1px solid #c0c0c0',
    '&:hover': {
      boxShadow: '0 0 3px 0 rgba(0, 0, 0, 0.8)',
    },
  },

  /* Column definiions */
  flexCol1: {
    flex: '1 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol2: {
    flex: '2 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol3: {
    flex: '3 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol4: {
    flex: '4 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexColAuto: {
    width: 'auto',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  /* Use to scale and hide columns in the title row */
  flexColAutoHidden: {
    width: 'auto',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
    visibility: 'hidden',
  },

  show: {
    display: 'block',
  },

  hide: {
    display: 'none',
  },

  pointer: {
    cursor: 'pointer',
  },
}));

const WizardPage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const id = match.params.id;
  const [wizardObject, setWizardObject] = useState({});
  const [wizardName, setWizardName] = useState('');
  // const [wizardDescription, setWizardDescription] = useState('');
  const [wizardSpecification, setWizardSpecification] = useState();

  // eslint-disable-next-line arrow-body-style
  const renderRanges = (specification) => {
    return (
      <div>
        {specification.fields['0'].name}.{specification.fields['1'].name}.{specification.fields['2'].name}:
        [0, {specification.fields['0'].capacity === '-1' ? (<span>&infin;</span>) : specification.fields['0'].capacity}]
        [0, {specification.fields['1'].capacity === '-1' ? (<span>&infin;</span>) : specification.fields['1'].capacity}]
        [0, {specification.fields['2'].capacity === '-1' ? (<span>&infin;</span>) : specification.fields['2'].capacity}]
      </div>
    );
  };

  useEffect(() => {
    const init = async (thisid) => {
      // wrap the API call
      const response = await wizardsAPI.getWizardById(thisid);
      if (!response) return;

      // success
      const wizard = response.wizard;
      setWizardObject(wizard);
      setWizardName(wizard.name);
      // setWizardDescription(wizard.description);
      setWizardSpecification(wizard.specification);
    };

    init(id);
  }, []);

  return (
    <>
      <Toolbar className={classes.header}>
        <Breadcrumbs
          separator={<NavigateNextIcon fontSize="small" />}
          aria-label="breadcrumb"
          component="div"
          data-cy="page-title"
        >
          <Typography display="inline" variant="h6" component="h1">
            Wizards
          </Typography>
          <Typography display="inline" variant="h6" component="h1">
            {wizardName}
          </Typography>
        </Breadcrumbs>

        <div>
          <LinkButton
            name="Edit"
            testName="edit_button"
            text="Edit"
            light
            type="button"
            linkTo={`/wizards/${id}/edit`}
          />

          <LinkButton
            name="All Wizards"
            testName="all_wizards_button"
            text="All Wizards"
            light
            type="button"
            linkTo="/wizards"
          />
        </div>
      </Toolbar>

      <Divider />

      <Grid container className={classes.root}>
        {/* SIDE BAR */}
        <SideBar
          setIsLoading={setIsLoading}
          setAlertProps={setAlertProps}
          wizardObject={wizardObject}
        />

        {/* MAIN CONTENT */}
        <Grid item xs={9} name="main-container" data-cy="main-container" overflow="visible">
          Boxes managed by {wizardName}

          {wizardSpecification ? renderRanges(JSON.parse(wizardSpecification)) : 'loading'}
        </Grid>
      </Grid>
    </>
  );
};

WizardPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default WizardPage;
