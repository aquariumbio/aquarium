import React, { useState, useEffect, useReducer } from 'react';
import PropTypes from 'prop-types';
import Typography from '@material-ui/core/Typography';
import ListItem from '@material-ui/core/ListItem';
import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';
import { Link as RouterLink } from 'react-router-dom';
import objectsAPI from '../../helpers/api/objects';
import AlertToast from '../shared/AlertToast';



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
    padding: '0 8px',
  },

  flex: {
    display: '-ms-flexbox',
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
    "&:hover": {
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
  var newIds = toggleId
  newIds[id] = !newIds[id]
  setToggleIds(newIds);

  triggerUpdate();
};

const ShowObjectTypeHandler = ({ objectTypes }) => {

  // NOTE: regarding toggleIds and triggerUpdate
  // toggleIds used to track show/hide state for object type details, takes the form { objectType.id => true/false }
  // triggerUpdate used to trigger a screen update.
  // - React does not change the screen when changing the toggleIds
  // - calling triggerUpdate() triggers a screen update (which also includes any state changes to toggleIds)
  const [toggleIds, setToggleIds] = useState({});
  const [, triggerUpdate] = useReducer(x => !x, false);
  const classes = useStyles();
  const [alertProps, setAlertProps] = useState({});

  const handleDelete = async (id) => {
    const response = await objectsAPI.delete(id);

    // break if the HTTP call resulted in an error ("return false" from API.js)
    // NOTE: the alert("break") is just there for testing. Whatever processing should be handled in API.js, and we just need stop the system from trying to continue...
    if (!response) {
      alert("break")
      return;
    }

    // process errors
    const errors = response["errors"];
    if (errors) {
      setAlertProps({
        message: errors, // JSON.stringify(errors, null, 2),
        severity: 'error',
        open: true,
      });
      return;
    }

    // success
    // simple solution - reload the page
    document.location.reload(true)

    // // removing the child in the DOM works causes the DOM and the virtual DOM to go out-of-sync
    // var element = document.getElementById('object_'+id)
    // element.parentNode.removeChild(element);

    // // removing the child in the DOM works causes the DOM and the virtual DOM to go out-of-sync
    // document.getElementById('object_'+id).outerHTML='';


    // // using "innerHTML" keeps the DOM and the virtual DOM in sync but causes problems with the AlertToast
    // document.getElementById('object_'+id).innerHTML='';
    //
    // setAlertProps({
    //   message: response["message"],
    //   severity: 'success',
    //   open: true,
    // });
  };

  return (
    <>
      <AlertToast
        open={alertProps.open}
        severity={alertProps.severity}
        message={alertProps.message}
      />

      <div className={classes.flexWrapper}>
        <div className={`${classes.flex} ${classes.flexTitle}`}>
          <Typography className={classes.flexCol1}><b>Name</b></Typography>
          <Typography className={classes.flexCol3}><b>Description</b></Typography>
          <Typography className={classes.flexColAutoHidden}>Edit</Typography>
          <Typography className={classes.flexColAutoHidden}>Delete</Typography>
        </div>
        {objectTypes.map((objectType) => (
          <div className={`${classes.flex} ${classes.flexRow}`} key = {`object_${objectType.id}`} >
            <Typography className={classes.flexCol1} >
              <Link className={ classes.pointer } onClick={ () => handleToggles(objectType.id, toggleIds, setToggleIds, triggerUpdate) } >{objectType.name}</Link>
            </Typography>
            <Typography className={classes.flexCol3} >
              {objectType.description}
              <span className={ toggleIds[objectType.id] ? classes.show : classes.hide }>
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
            <Typography className={classes.flexColAuto} >
              <Link component={RouterLink} to={`/object_types/${objectType.id}/edit`}>Edit</Link>
            </Typography>
            <Typography className={classes.flexColAuto} >
              <Link className={classes.pointer} onClick={ () => handleDelete(objectType.id) } >Delete</Link>
            </Typography>
          </div>
        ))}
      </div>
    </>
  );
};

export default ShowObjectTypeHandler;


