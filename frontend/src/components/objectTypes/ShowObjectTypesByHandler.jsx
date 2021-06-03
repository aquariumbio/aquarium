import React, { useState, useReducer } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import ListItem from '@material-ui/core/ListItem';
import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';

import objectsAPI from '../../helpers/api/objects';
import globalUseSyles from '../../globalUseStyles';

const useStyles = makeStyles((theme) => ({
  root: {
    height: 'calc(100% - 64px)',
  },

  inventory: {
    fontSize: '0.875rem',
    marginBottom: theme.spacing(2),
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
  const globalClasses = globalUseSyles();

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
      <div className={globalClasses.flexWrapper}>
        <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
          <Typography className={globalClasses.flexCol1}><b>Name</b></Typography>
          <Typography className={globalClasses.flexCol3}><b>Description</b></Typography>
          <Typography className={globalClasses.flexColAutoHidden}>Edit</Typography>
          <Typography className={globalClasses.flexColAutoHidden}>Delete</Typography>
        </div>

        {objectTypes.map((objectType) => (
          <div className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`object_${objectType.id}`}>
            <Typography className={globalClasses.flexCol1}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link data-cy={`show_${objectType.id}`} className={classes.pointer} onClick={() => handleToggles(objectType.id, toggleIds, setToggleIds, triggerUpdate)}>{objectType.name}</Link>
            </Typography>
            <Typography className={globalClasses.flexCol3}>
              {objectType.description}
              <span className={toggleIds[objectType.id] ? classes.show : classes.hide}>
                <ListItem>
                  <b>Min/Max</b>: {objectType.min} / {objectType.max}
                </ListItem>
                <ListItem>
                  <b>Unit/Cost</b>: {objectType.unit} / {objectType.cost}
                </ListItem>
                <ListItem>
                  <b>Handler</b>: {objectType.handler}
                </ListItem>
                <ListItem>
                  <b>Release</b>: {objectType.release_method}
                </ListItem>
                <ListItem>
                  <b>Safety</b>: {objectType.safety}
                </ListItem>
                <ListItem>
                  <b>Cleanup</b>: {objectType.cleanup}
                </ListItem>
                <ListItem>
                  <b>Data</b>: {objectType.data}
                </ListItem>
                <ListItem>
                  <b>Vendor</b>: {objectType.vendor}
                </ListItem>
                <ListItem>
                  <b>Location Prefix</b>: {objectType.prefix}
                </ListItem>
              </span>
            </Typography>

            <Typography className={globalClasses.flexColAuto}>
              <Link data-cy={`edit_${objectType.id}`} component={RouterLink} to={`/object_types/${objectType.id}/edit`}>Edit</Link>
            </Typography>

            <Typography className={globalClasses.flexColAuto}>
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
