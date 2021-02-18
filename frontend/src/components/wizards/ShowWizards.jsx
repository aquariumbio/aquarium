import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';
import wizardsAPI from '../../helpers/api/wizards';

const useStyles = makeStyles((theme) => ({
  root: {
    height: 'calc(100% - 64px)',
  },

  inventory: {
    fontSize: '0.875rem',
    marginBottom: theme.spacing(2),
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

const ShowWizards = ({ wizards }) => {
  const classes = useStyles();

  const handleDelete = async (wizard) => {
    const response = await wizardsAPI.delete(wizard.id);
    if (!response) return;

    // success
    sessionStorage.alert = JSON.stringify({
      message: 'deleted',
      severity: 'success',
      open: true,
    });

    window.location.reload();
  };

  return (
    <>
      <div className={classes.flexWrapper}>
        <div className={`${classes.flex} ${classes.flexTitle}`}>
          <Typography className={classes.flexCol1}><b>Name</b></Typography>
          <Typography className={classes.flexCol3}><b>Description</b></Typography>
          <Typography className={classes.flexColAutoHidden}>Edit</Typography>
          <Typography className={classes.flexColAutoHidden}>Delete</Typography>
        </div>

        {wizards.map((wizard) => (
          <div className={`${classes.flex} ${classes.flexRow}`} key={`object_${wizard.id}`}>
            <Typography className={classes.flexCol1}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link className={classes.pointer} onClick={() => alert('wizard page')}>{wizard.name}</Link>
            </Typography>

            <Typography className={classes.flexCol3}>
              {wizard.description}
            </Typography>

            <Typography className={classes.flexColAuto}>
              <Link component={RouterLink} to={`/wizards/${wizard.id}/edit`}>Edit</Link>
            </Typography>

            <Typography className={classes.flexColAuto}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link className={classes.pointer} onClick={() => handleDelete(wizard)}>Delete</Link>
            </Typography>
          </div>
        ))}
      </div>
    </>
  );
};

ShowWizards.propTypes = {
  wizards: PropTypes.isRequired,
};

export default ShowWizards;
