import React, { useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';

import { LinkButton, StandardButton } from '../shared/Buttons';
import tokensAPI from '../../helpers/api/tokensAPI';

// Route: /object_types
// Linked in LeftHamburgeMenu

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
}));

const GroupPage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();

  const handleSubmit = async () => {
    alert('TODO: add member');
  };

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
      <Toolbar className={classes.header}>
        <Breadcrumbs
          separator={<NavigateNextIcon fontSize="small" />}
          aria-label="breadcrumb"
          component="div"
          data-cy="page-title"
        >
          <Typography display="inline" variant="h6" component="h1">
            Groups
          </Typography>
          <Typography display="inline" variant="h6" component="h1">
            current letter
          </Typography>
          <Typography display="inline" variant="h6" component="h1">
            current group
          </Typography>
        </Breadcrumbs>

        <div>
          <LinkButton
            name="All Groups"
            testName="all_groups_button"
            text="All Groups"
            light
            type="button"
            linkTo="/groups"
          />
        </div>
      </Toolbar>

      <Divider />

      <div className={classes.wrapper}>
        <div>
          <StandardButton
            name="New Member"
            testName="new_member_btn"
            text="New Member"
            dark
            type="button"
            handleClick={handleSubmit}
          />
        </div>

        TODO: list members
      </div>
    </>
  );
};

GroupPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  ssetAlertProps: PropTypes.func.isRequired,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default GroupPage;
