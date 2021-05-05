import React, { useState, useReducer } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import ListItem from '@material-ui/core/ListItem';
import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';

import ShowObjectTypeDetails from './ShowObjectTypeDetails';
import objectsAPI from '../../helpers/api/objects';

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
    borderBottom: '2px solid #ccc',
  },

  /* Data Row */
  flexRow: {
    padding: '8px 0',
    borderBottom: '1px solid #ccc',
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

// change the state of toggleIds[objectType.id] and trigger React to update the screen
// (see NOTE below)
const handleToggles = (id, toggleId, setToggleIds, triggerUpdate) => {
  const newIds = toggleId;
  newIds[id] = !newIds[id];
  setToggleIds(newIds);
  triggerUpdate();
};

// eslint-disable-next-line no-unused-vars
const ShowObjectTypesByHandler = ({ objectTypes, setIsLoading, setAlertProps }) => {
  // NOTE: regarding toggleIds and triggerUpdate
  // eslint-disable-next-line max-len
  // toggleIds used to track show/hide state for object type details, takes the form { objectType.id => true/false }
  // triggerUpdate used to trigger a screen update.
  // - React does not change the screen when changing the toggleIds
  //   eslint-disable-next-line max-len
  // - calling triggerUpdate() triggers a screen update (which also includes any state changes to toggleIds)
  const [toggleIds, setToggleIds] = useState({});
  // eslint-disable-next-line arrow-parens
  const [, triggerUpdate] = useReducer(x => !x, false);

  const classes = useStyles();

  const handleDelete = async (id) => {
    const response = await objectsAPI.delete(id);
    if (!response) return;

    // success
    // pass alert popup in localStorage (does not work if pass as object, so pass as JSON string)
    localStorage.alert = JSON.stringify({
      message: response.message,
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

        {objectTypes.map((objectType) => (
          <div className={`${classes.flex} ${classes.flexRow}`} key={`object_${objectType.id}`}>
            <Typography className={classes.flexCol1}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link data-cy={`show_${objectType.id}`} className={classes.pointer} onClick={() => handleToggles(objectType.id, toggleIds, setToggleIds, triggerUpdate)}>{objectType.name}</Link>
            </Typography>
            <Typography className={classes.flexCol3}>
              {objectType.description}
              <span className={toggleIds[objectType.id] ? classes.show : classes.hide}>
                <ShowObjectTypeDetails objectType={objectType} />
              </span>
            </Typography>

            <Typography className={classes.flexColAuto}>
              <Link data-cy={`edit_${objectType.id}`} component={RouterLink} to={`/object_types/${objectType.id}/edit`}>Edit</Link>
            </Typography>

            <Typography className={classes.flexColAuto}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link data-cy={`delete_${objectType.id}`} className={classes.pointer} onClick={() => handleDelete(objectType.id)}>Delete</Link>
            </Typography>
          </div>
        ))}
      </div>
    </>
  );
};

ShowObjectTypesByHandler.propTypes = {
  objectTypes: PropTypes.isRequired,
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
};

export default ShowObjectTypesByHandler;
