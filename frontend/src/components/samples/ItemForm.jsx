import React, { useState, useEffect, useReducer } from 'react';
import { useHistory } from 'react-router-dom';
import PropTypes from 'prop-types';
import { Link as RouterLink } from 'react-router-dom';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Grid from '@material-ui/core/Grid';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import Link from '@material-ui/core/Link';
import FormGroup from '@material-ui/core/FormGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Switch from '@material-ui/core/Switch';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import Button from '@material-ui/core/Button';

import { StandardButton } from '../shared/Buttons';
import itemsAPI from '../../helpers/api/itemsAPI';
import objectsAPI from '../../helpers/api/objectsAPI';
import samplesAPI from '../../helpers/api/samplesAPI';

// Route: /object_types
// Linked in LeftHamburgeMenu
const useStyles = makeStyles((theme) => ({
  box: {
    border: '1px solid black',
    padding: '16px',
    margin: '16px 0',
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
    overflowWrap: 'break-word',
  },

  /* Bottom of table */
  flexBottom: {
    borderBottom: '1px solid #ccc',
    borderRight: '1px solid #ccc',
  },

  /* Data Row */
  flexRow: {
  },

  /* Column definiions */
  flexCol1: {
    flex: '1 1 0',
    padding: '8px',
    minWidth: '0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
  },

  // &::before creates a square box
  flexCol1x: {
    flex: '1 1 0',
    minWidth: '0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',

    "&::before": {
      content: `''`,
      float:'left',
      paddingTop:'100%',
    },
  },

  flexCol2: {
    flex: '2 1 0',
    padding: '8px',
    minWidth: '0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
  },

  flexCol3: {
    flex: '3 1 0',
    padding: '8px',
    minWidth: '0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
  },

  flexCol4: {
    flex: '4 1 0',
    padding: '8px',
    minWidth: '0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
  },

  flexColAuto: {
    width: 'auto',
    paddingRight: '24px',
    paddingLeft: '24px',
    minWidth: '0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
  },

  flexColFixed40: {
    width: '40px',
    padding: '8px',
    minWidth: '0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
  },

  show: {
    display: 'block',
  },

  hide: {
    display: 'none',
  },

  visible: {
    visibility: 'visible',
  },

  hidden: {
    visibility: 'hidden',
  },

  mt16: {
    marginTop: '16px',
  },

  center: {
    textAlign: 'center',
  },

  right: {
    textAlign: 'right',
  },

  pointer: {
    cursor: 'pointer',
  },

  pointer_no_hover: {
    cursor: 'pointer',

    '&:hover': {
      textDecoration: 'none',
    }
  },

  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  /* flex */
  flexCardWrapper: {
    margin: '0 -1.5%',
  },

  flexCard25: {
    flex: '0 0 22%',
    paddingRight: '1.5%',
    marginLeft: '1.5%',
    minWidth: '0',
    border: '1px solid black',
    padding: '8px',
    marginBottom: '40px',
    fontSize: '12px',
    cursor: 'pointer',
    height: '400px',
    overflowY: 'scroll',
    position: 'relative',

    '&:hover': {
      backgroundColor: '#eee',
    },
  },

  flexCardLabel: {
    fontWeight: 'bold',
    wordBreak: 'break-all',
  },

  flexCardText: {
    marginBottom: '16px',
    wordBreak: 'break-all',
  },

  logoImage: {
    position: 'absolute',
  },

  logoPopout: {
    position: 'absolute',
    width: '24px',
    right: '8px',
    textAlign: 'right',
    fontSize: '20px',
    fontWeight: 'bold',
    cursor: 'pointer',

    '&:hover': {
      textDecoration: 'none',
    }
  },

  logoText: {
    marginLeft: '40px',
    marginRight: '32px',
    marginBottom: '16px',
  },

  textTitle: {
    fontSize: '18px',
    marginBottom: '4px',
  },

  mb4: {
    marginBottom: '4px',
  },

  mb8: {
    marginBottom: '8px',
  },

  mb16: {
    marginBottom: '16px',
  },

  mr16: {
    marginRight: '16px',
  },

  textBold: {
    fontWeight: 'bold',
  },

  textInfo: {
    color: '#333',
  },

  relative: {
    position: 'relative',
  },

  absolute: {
    position: 'absolute',
  },

  mtm7: {
    marginTop: '-7px',
  },

  mtm8: {
    marginTop: '-8px',
  },

  width100p: {
    width: '100%',
  },

  dark: {
    backgroundColor: theme.palette.primary.main,
    color: '#fff',
  },

  deselected: {
    padding: '8px',
  },

  selected: {
    border: '2px dashed black',
    padding: '7px 6px 6px 7px',
  },

  selectList: {
    maxHeight: '322px',
    overflowY: 'scroll',
    borderLeft: '1px solid #777',
    borderBottom: '1px solid #777',
    borderRight: '1px solid #777',
  },

  selectItem: {
    cursor: 'pointer',
    padding: '0 8px',
    height: '20px',
    lineHeight: '20px',

    '&:hover': {
      backgroundColor: '#ccc',
    }
  },

  remove: {
    cursor: 'pointer',
    fontWeight: 'bold',
    fontSize: '150%',
    position: 'absolute',
    marginLeft: '8px',
    marginTop: '-6px',
  },

  p100: {
    width: '100%',
    padding: '4px 8px',
  },
}));

// eslint-disable-next-line no-unused-vars
const ItemForm = ({ setIsLoading, setAlertProps, itemId, setItemId }) => {
  const classes = useStyles();
  const history = useHistory();

  const [item, setItem] = useState({});
  const [objectType, setObjectType] = useState({});

  useEffect(() => {
    const init = async (id) => {
//       const response1 = await itemsAPI.getItemById(id);
//       if (!response1) return;
//
//       // set item + object type
//       setItem(response1.item);
//       setObjectType(response1.object_type);
//
//       // set rows and columns
//       setRows([...Array(response1.object_type.rows || 1).keys()]);
//       setColumns([...Array(response1.object_type.columns || 12).keys()]);
//
//       // map item data
//       let temp = new Object
//       response1.item.map((c) => (
//         temp={...temp,[`${c.row}.${c.column}`]: c.sample_id}
//       ))
//
//       // set item
//       setItem(temp)
    }

    init();
  }, []);

  return (
    <>
      <div>
        <Button variant="outlined" onClick={() => {setItemId(0)}}>Close</Button>
      </div>

      <Typography className={`${classes.mb8} ${classes.mt16}`}>
        Item: {itemId}: {objectType.name}
      </Typography>

      <Typography className={`${classes.mb8} ${classes.mt16}`}>
        Data
      </Typography>
      <Typography className={classes.mb8}>
        TODO: Add Data
      </Typography>

      <Typography className={`${classes.mb8} ${classes.mt16}`}>
        History
      </Typography>
      <Typography className={classes.mb8}>
        TODO: Add History
      </Typography>
    </>

  );
};

ItemForm.propTypes = {
  itemTypeId: PropTypes.isRequired,
  setItemTypeId: PropTypes.isRequired,
};

export default ItemForm;

