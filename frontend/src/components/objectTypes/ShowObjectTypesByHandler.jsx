import React, { useState, useReducer } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import ListItem from '@material-ui/core/ListItem';
import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';

import ShowObjectTypeDetails from './ShowObjectTypeDetails';
import objectsAPI from '../../helpers/api/objectsAPI';
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

// eslint-disable-next-line no-unused-vars
const ShowObjectTypesByHandler = ({ objectTypes, setIsLoading, setAlertProps }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();

  // show/hide toggles
  const [toggleIds, setToggleIds] = useState({});

  // change the state of toggleIds[id]
  const handleToggles = (id) => {
    const newIds = toggleIds;
    newIds[id] = !newIds[id];

    setToggleIds({...toggleIds, id:newIds[id]})
  };

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
              <Link data-cy={`show_${objectType.id}`} className={globalClasses.pointer} onClick={() => handleToggles(objectType.id)}>{objectType.name}</Link>
            </Typography>
            <Typography className={globalClasses.flexCol3}>
              {objectType.description}
              <span className={toggleIds[objectType.id] ? globalClasses.show : globalClasses.hide}>
                <ShowObjectTypeDetails objectType={objectType} />
              </span>
            </Typography>

            <Typography className={globalClasses.flexColAuto}>
              <Link data-cy={`edit_${objectType.id}`} component={RouterLink} to={`/object_types/${objectType.id}/edit`}>Edit</Link>
            </Typography>

            <Typography className={globalClasses.flexColAuto}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link data-cy={`delete_${objectType.id}`} className={globalClasses.pointer} onClick={() => handleDelete(objectType.id)}>Delete</Link>
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
