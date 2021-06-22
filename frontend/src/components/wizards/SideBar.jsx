import React, { useState, useEffect } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';
import Pluralize from 'pluralize';

import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import Link from '@material-ui/core/Link';
import globalUseSyles from '../../globalUseStyles';

import tokensAPI from '../../helpers/api/tokensAPI';
// import wizardsAPI from '../../helpers/api/wizardsAPI';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  mr8: {
    marginRight: '8px',
  },

  letter: {
    color: theme.palette.primary.main,
  },
}));

// eslint-disable-next-line no-unused-vars
const SideBar = ({ setIsLoading, setAlertProps, wizard }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();

  // initialize to all and get permissions
  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await tokensAPI.isAuthenticated();
      if (!response) return;

      // success
    };

    init();
  }, []);

  return (
    <>
      <Grid
        item
        xs={4}
        name="side-bar"
        data-cy="side-bar"
        className={`${classes.root} ${globalClasses.wrapper}`}
      >
        <Typography variant="h5">
          {wizard.containers ? Pluralize('Container', 2) : ''}{' '}
          managed by {wizard.name}
        </Typography>
        <p>
          {wizard.containers ? (
            <>
            {wizard.containers.map((container) => (
              <>
                <Link className={`${classes.mr8}`} component={RouterLink} to={`/object_types/${container.id}/show`}>{container.name}</Link>
                {' '}
              </>
            ))}
            </>
          ) : (
            'loading...'
          )}
        </p>

        <Typography variant="h5">
          Associating Wizards
        </Typography>
        <p>Go to the object type's edit page, or new page if you are creating a new object type, and enter the name of the wizard in for the "Location Prefix" field. All new items with that object type will use the wizard associated with that name, if there is one defined. Note that multiple object types can use the same wizard. For example, we store Primer Aliquots, Primer Stocks, Plasmid Stocks, etc. in the same type of freezer box.</p>
      </Grid>
    </>
  );
};

SideBar.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  wizard: PropTypes.isRequired,
};

export default SideBar;
