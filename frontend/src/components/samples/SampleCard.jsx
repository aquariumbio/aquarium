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
import samplesAPI from '../../helpers/api/samplesAPI';
import objectsAPI from '../../helpers/api/objectsAPI';
import itemsAPI from '../../helpers/api/itemsAPI';
import globalUseSyles from '../../globalUseStyles';

// Route: /object_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles(() => ({
  box: {
    border: '1px solid black',
    padding: '16px',
  },

  /* CUSTOM FLEX */

  /* Title row */
  flexTitle: {
    padding: '8px 0',
    backgroundColor: '#eee',
    borderLeft: '1px solid #ccc',
    borderRight: '1px solid #ccc',
    borderTop: '1px solid #ccc',
  },

  /* Bottom of table */
  flexBottom: {
    borderBottom: '1px solid #ccc',
  },

  /* Data Row */
  flexRow: {
    padding: '8px 0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
    borderRight: '1px solid  #ccc',
  },

  flexRowSel: {
    padding: '8px 0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
    borderRight: '1px solid  #ccc',
    backgroundColor: '#d6e9ff',
  },

  /* Data Row */
  flexTitleSub: {
    padding: '4px 0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
    borderRight: '1px solid  #ccc',
    fontWeight: 'bold',
  },

  /* Data Row */
  flexRowSub: {
    padding: '4px 0',
    borderTop: '1px dashed #ccc',
    borderLeft: '1px solid  #ccc',
    borderRight: '1px solid  #ccc',
  },

  mt16: {
    marginTop: '16px',
  },

  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  /* custom flex */

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

  textBold: {
    fontWeight: 'bold',
  },

  textInfo: {
    color: '#808080',
  },

  mb4: {
    marginBottom: '4px',
  },

  mb16: {
    marginBottom: '16px',
  },

  mr16: {
    marginRight: '16px',
  },

  mtm8: {
    marginTop: '-8px',
  },
}));


// eslint-disable-next-line no-unused-vars
const SampleCard = ({ sampleId, setSampleId, setSampleTypeId, setCollectionId, setCollectionTypeId, setItemId }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();
  const history = useHistory();

  const [sample, setSample] = useState();
  const [inventory, setInventory] = useState([]);

  const [state, setState] = useState({});
  const [objectTypes, setObjectTypes] = useState([{id:1, name:'name1'},{id:2, name:'name2'}]);

  const handleToggle = (event) => {
    setState({ ...state, [event.target.name]: event.target.checked });
  };

  // show/hide toggles
  const [toggleIds, setToggleIds] = useState({});

  // change the state of toggleIds[id]
  const handleToggles = (id) => {
    const newIds = toggleIds;
    newIds[id] = !newIds[id];

    setToggleIds({...toggleIds, id:newIds[id]})
  };

  const init = async (id) => {
    // wrap the API calls
    const response1 = await samplesAPI.getById(id);
    const response2 = await objectsAPI.getBySample(id);
    if (!response1 || !response2) return;

    // success
    setSample(response1.sample);
    setInventory(response1.inventory);
    setObjectTypes(response2.object_types);
  };

  useEffect(() => {
    init(sampleId);
  }, []);

  const handleClick = async (id) => {
    init(id);
  }

  const handleCollectionClick = async (id, type_id) => {
    event.preventDefault();

    setCollectionId(id);
    setCollectionTypeId(type_id)
  }

  const handleItemClick = async (id) => {
    event.preventDefault();

    setItemId(id);
  }

  const handleAddItem = async (id) => {
    const formData = {
      object_type_id: id,
      sample_id: sampleId,
    }

    const response1 = await itemsAPI.create(formData);
    if (!response1) return;

    // success
    init(sampleId);
  }

  const handleItemDiscard = async (id) => {
    const response1 = await itemsAPI.discard(id);
    if (!response1) return;

    // success
    init(sampleId);
  }

  return (
    <>

      <Typography>
        <p className={globalClasses.right}>
          <Button className={classes.mr16} variant="outlined" onClick={() => {setSampleTypeId(sample.sample_type_id)}}>Edit</Button>
          <Button variant="outlined" onClick={() => {setSampleId(0)}}>Close</Button>
        </p>
      </Typography>

      <div className={classes.box}>
        <Grid container>
          {/* METADATA */}
          <Grid
            item
            xs={3}
          >
            {sample ? (
              <div className={globalClasses.relative}>
                  <img src='/beaker.png' className={classes.logoImage}/>
                  <div className={classes.logoText}>
                    <div className={classes.textTitle}>
                      {sample.name}
                    </div>
                    <div className={`${classes.mb4} ${classes.textInfo}`}>
                      {sample.sample_type}
                    </div>
                    <div className={`${classes.mb4} ${classes.textInfo}`}>
                      Added by:
                      {' '}
                      {sample.user_name}
                    </div>
                  </div>

                  <Divider />

                  <div className={classes.flexCardText}>
                    <span className={classes.textBold}>ID:</span>
                    {' '}
                    {sample.id}
                  </div>

                  <div className={classes.flexCardLabel}>
                    Description
                  </div>
                  <div className={classes.flexCardText}>
                    {sample.description || '-'}
                  </div>

                  {sample.fields.map((k) => (
                    <>
                      <div className={classes.flexCardLabel}>
                        {k.name}
                      </div>
                      <div className={classes.flexCardText}>
                        {k.type == 'sample' ? (
                          <>
                            {k.child_sample_id ? <Link className={globalClasses.pointer} onClick={() => handleClick(k.child_sample_id)}>{k.child_sample_id}: {k.child_sample_name}</Link> : <span>-</span>}
                          </>
                        ) : (
                          k.type == 'url' ? (
                            <>
                              {k.value ? <Link className={globalClasses.pointer} onClick={() => window.open(k.value, "_blank")}>{k.value}</Link> : <span>-</span>}
                            </>
                          ) : (
                            <>
                              {k.value || <span>-</span>}
                            </>
                          )
                        )}
                      </div>
                    </>
                  ))}

                  <div className={classes.mb16}>
                    <span className={classes.textBold}>Added:</span>
                    {' '}
                    <span className={classes.textInfo}>{sample.created_at.substr(0,10)}</span>
                  </div>
              </div>
            ) : (
              <>
                loading...
              </>
            )}
          </Grid>

          {/* INVNETORY */}
          <Grid
            item
            xs={9}
          >
            <div className={globalClasses.flexWrapper}>
              <div className={`${globalClasses.flex} ${classes.flexTitle}`}>
                <Typography className={`${globalClasses.flexColFixed40} ${globalClasses.center}`}>
                  &nbsp;
                </Typography>
                <Typography className={globalClasses.flexCol4}>
                  <b>Object Type</b>
                </Typography>
                <Typography className={`${globalClasses.flexCol1} ${globalClasses.right}`}>
                  <b>In Inventory</b>
                </Typography>
                <Typography className={`${globalClasses.flexCol1} ${globalClasses.right}`}>
                  <b>Discarded</b>
                </Typography>
                <Typography className={`${globalClasses.flexColFixed40} ${globalClasses.center} ${globalClasses.hidden}`}>
                  &nbsp;
                </Typography>
                <Typography className={globalClasses.flexCol1}>
                  &nbsp;
                </Typography>
              </div>

              <div className={classes.flexBottom}>
                {inventory.map((group,index) => (
                  <>
                    <div className={`${globalClasses.flex} ${toggleIds[index] ? classes.flexRowSel : classes.flexRow}`}  key={`index_${index}`}>
                      <Typography className={`${globalClasses.flexColFixed40} ${globalClasses.center} ${globalClasses.pointer_no_hover}`} onClick={() => handleToggles(index)}>
                        &#x2195;
                      </Typography>
                      <Typography className={`${globalClasses.flexCol4} ${globalClasses.pointer_no_hover}`} onClick={() => handleToggles(index)} cy={`group-${group.type_id}`}>
                        {group.type}
                      </Typography>
                      <Typography className={`${globalClasses.flexCol1} ${globalClasses.right} ${globalClasses.pointer_no_hover}`} onClick={() => handleToggles(index)}>
                        {group.count_inventory}
                      </Typography>
                      <Typography className={`${globalClasses.flexCol1} ${globalClasses.right} ${globalClasses.pointer_no_hover}`} onClick={() => handleToggles(index)}>
                        {group.count_deleted}
                      </Typography>
                      <Typography className={`${globalClasses.flexColFixed40} ${globalClasses.center} ${globalClasses.hidden}`}>
                        &nbsp;
                      </Typography>
                      <Typography className={`${globalClasses.flexCol1} ${classes.mtm8} ${globalClasses.relative}`}>
                        <Typography className={`${globalClasses.absolute}`}>
                          <FormGroup className={ toggleIds[index] ? globalClasses.show : globalClasses.hide }>
                            <FormControlLabel
                              control={<Switch onChange={handleToggle} name={`checked_${index}`} />}
                              label={<span style={{ fontSize: '13px' }}>Discarded</span>}
                              cy={`toggle-${group.type_id}`}
                            />
                          </FormGroup>
                        </Typography>
                      </Typography>
                    </div>

                    <div className={toggleIds[index] ? globalClasses.show : globalClasses.hide}>
                      <div className={`${globalClasses.flex} ${classes.flexTitleSub}`}>
                        <div className={`${globalClasses.flexColFixed40} ${globalClasses.center}`}>
                          &nbsp;
                        </div>
                        <div className={globalClasses.flexCol1}>
                          Item #
                        </div>
                        <div className={globalClasses.flexCol1}>
                          Location
                        </div>
                        <div className={`${globalClasses.flexCol1} ${globalClasses.right}`}>
                          Added
                        </div>
                        <div className={globalClasses.flexColAuto}>
                          <span className={globalClasses.hidden}>&#128465;</span>
                        </div>
                      </div>

                      {group.data.map((item) => (
                        <div className = {item.location == 'deleted' ? ( state[`checked_${index}`] ? globalClasses.show : globalClasses.hide ) : ''}>
                          <div className={`${globalClasses.flex} ${classes.flexRowSub}`}>
                            <div className={`${globalClasses.flexColFixed40} ${globalClasses.center}`}>
                              &nbsp;
                            </div>
                            <div className={globalClasses.flexCol1} cy={`item-${item.item_id}`}>
                              {item.collections ? (
                                <>
                                  <Link className={globalClasses.pointer} onClick={() => handleCollectionClick(item.item_id, item.type_id)}>{item.item_id}</Link>
                                  {item.collections.map((part) => (
                                    <div>
                                      &rarr; row {part.row + 1} col {part.column + 1}
                                    </div>
                                  ))}
                                </>
                              ) : (
                                <Link className={globalClasses.pointer} onClick={() => handleItemClick(item.item_id)}>{item.item_id}</Link>
                              )}
                            </div>
                            <div className={globalClasses.flexCol1}>
                              {item.location}
                            </div>
                            <div className={`${globalClasses.flexCol1} ${globalClasses.right}`}>
                              {item.date && item.date.substr(0,10)}
                            </div>
                            <div className={globalClasses.flexColAuto}>
                              <span className={`${globalClasses.pointer} ${item.location == 'deleted' ? globalClasses.hidden : globalClasses.visible}`} onClick={() => handleItemDiscard(item.item_id)}>&#128465;</span>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </>
                ))}
              </div>
              <br />

              <TextField
                name="add_item"
                fullWidth
                id="add_item"
                value="0"
                onChange={(event) => handleAddItem(event.target.value)}
                variant="outlined"
                type="string"
                inputProps={{
                  'aria-label': 'add_item',
                  'data-cy': 'add_item',
                }}
                select
              >
                <MenuItem key="0" value="0">Add Item</MenuItem>
                {objectTypes.map((objectType) => (
                  <MenuItem key={objectType.id} value={objectType.id}> {objectType.name}</MenuItem>
                ))}
              </TextField>
            </div>

          </Grid>
        </Grid>
      </div>
    </>

  );
};

SampleCard.propTypes = {
  sampleId: PropTypes.isRequired,
};

export default SampleCard;
