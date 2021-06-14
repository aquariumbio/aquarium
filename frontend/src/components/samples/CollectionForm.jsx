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
import sampleAPI from '../../helpers/api/sampleAPI';

// Route: /object_types
// Linked in LeftHamburgeMenu
const useStyles = makeStyles((theme) => ({
  box: {
    border: '1px solid black',
    padding: '16px',
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

  flexCol1x: {
    flex: '1 1 0',
    minWidth: '0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
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

  mt8: {
    marginTop: '8px',
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
    cursor: 'pointer',
    padding: '8px',
  },

  selected: {
    cursor: 'pointer',
    border: '2px dashed black',
    padding: '7px 6px 6px 7px',
  },

  selectList: {
    height: '320px',
    overflowY: 'scroll',
    border: '1px solid black',
  },

  selectItem: {
    cursor: 'pointer',
    padding: '0 4px',
    height: '20px',
    lineHeight: '20px',

    '&:hover': {
      backgroundColor: '#ccc',
    }
  },
}));

// eslint-disable-next-line no-unused-vars
const CollectionForm = ({ collectionId, collectionTypeId, setCollectionTypeId }) => {
  const classes = useStyles();
  const history = useHistory();

  const [item, setItem] = useState({});
  const [collection, setCollection] = useState({});
  const [objectType, setObjectType] = useState({});
  const [quickSearch, setQuickSearch] = useState('');
  const [list, setList] = useState([]);

  // used to set rows/columns in case they are not defined in object_type (backend quirk)
  const [rows, setRows] = useState([]);
  const [columns, setColumns] = useState([]);

  const [rowSel, setRowSel] = useState(-1);
  const [colSel, setColSel] = useState(-1);

  useEffect(() => {
    const initNew = async () => {
      const formData = {
        object_type_id: collectionTypeId,
      }

      const response1 = await itemsAPI.create(formData);
      if (!response1) return;

      // set item + object type
      setItem(response1.item);
      setObjectType(response1.object_type);

      // set rows and columns
      setRows([...Array(response1.object_type.rows || 1).keys()]);
      setColumns([...Array(response1.object_type.columns || 12).keys()]);
    };

    const initEdit = async (id) => {
      const response1 = await itemsAPI.getCollectionById(id);
      if (!response1) return;

      // set item + object type
      setItem(response1.item);
      setObjectType(response1.object_type);

      // set rows and columns
      setRows([...Array(response1.object_type.rows || 1).keys()]);
      setColumns([...Array(response1.object_type.columns || 12).keys()]);

      // map collection data
      let temp = new Object
      response1.collection.map((c) => (
        temp={...temp,[`${c.row}.${c.column}`]: c.sample_id}
      ))

      // set collection
      setCollection(temp)
    }

    collectionId == 0 ? initNew() : initEdit(collectionId);
  }, []);

  const handleRC = (r,c) => {
    rowSel == r && colSel == c ? (
      setRowSel(-1),
      setColSel(-1)
    ) : (
      setRowSel(r),
      setColSel(c)
    )
  };

  const handleSearch = async () => {
    setQuickSearch(event.target.value)

    const response1 = await sampleAPI.getQuickSearch('testing','1.2.3');
    if (!response1) return;

    // set item + object type
    setList(response1);
  };

  const handleSelect = async (event) => {
    alert(`assign ${event.target.id} to row ${rowSel} column ${colSel}`)
    setList([])
    setQuickSearch('')
  }

  const handleRemove = async () => {
    alert(`remove - row ${rowSel} column ${colSel}`)
  }

  return (
    <>

      <Typography>
        <p className={classes.right}>
          <Button variant="outlined" onClick={() => {setCollectionTypeId(0)}}>Close</Button>
        </p>
      </Typography>

      <div className={classes.box}>
        <Typography>
          Collection: {item.id}: {objectType.name}
        </Typography>

        <div className={classes.flexBottom}>

          <div className={`${classes.flex} ${classes.flexRow} ${classes.dark}`}>
            <Typography className={classes.flexColFixed40}>
              &nbsp;
            </Typography>
            {columns.map((column) =>(
              <Typography className={classes.flexCol1}>
                {column + 1}
              </Typography>
            ))}
          </div>

          {rows.map((row) =>(
            <div className={`${classes.flex} ${classes.flexRow}`}>
              <Typography className={`${classes.flexColFixed40} ${classes.dark}`}>
                {row + 1}
              </Typography>
              {columns.map((column,cIndex) =>(
                <Typography className={`${classes.flexCol1x} ${rowSel == row && colSel == column ? classes.selected : classes.deselected}`} id={`${row},${column}`} onClick={() => handleRC(row, column)}>
                  {collection[`${row}.${column}`]}
                </Typography>
              ))}
            </div>
          ))}
        </div>

      </div>

      {rowSel != -1 && (
        <>
          {collection[`${rowSel}.${colSel}`] ? (
            <>
              <Typography className={classes.mt16}>
                Remove Sample from Selection
              </Typography>
              <Typography className={classes.mt8}>
                <Button variant="outlined" onClick={handleRemove}>Remove</Button>
              </Typography>
            </>
          ) : (
            <>
              <Typography className={classes.mt16}>
                Assign Sample to Selection
              </Typography>
              <Typography className={classes.mt8}>
                <input value={quickSearch} onChange={(event) => handleSearch(event)} />
                {list.length!=0 && (
                  <div className={classes.selectList}>
                    {list.map((l) => (
                      <div id={l.id} className={classes.selectItem} onClick={(event) => handleSelect(event)}>
                        {l.id}: {l.name}
                      </div>
                    ))}
                  </div>
                )}
              </Typography>
            </>
          )}
        </>
      )}

    </>

  );
};

CollectionForm.propTypes = {
  collectionTypeId: PropTypes.isRequired,
  setCollectionTypeId: PropTypes.isRequired,
};

export default CollectionForm;

