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
import sampleAPI from '../../helpers/api/sampleAPI';
import objectsAPI from '../../helpers/api/objectsAPI';
import itemsAPI from '../../helpers/api/itemsAPI';

// Route: /object_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles(() => ({
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

  /* Column definiions */
  flexCol1: {
    flex: '1 1 0',
    paddingRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol2: {
    flex: '2 1 0',
    paddingRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol3: {
    flex: '3 1 0',
    paddingRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol4: {
    flex: '4 1 0',
    paddingRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexColAuto: {
    width: 'auto',
    paddingRight: '24px',
    paddingLeft: '24px',
    minWidth: '0',
  },

  flexColFixed40: {
    width: '40px',
    paddingRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
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
}));


// eslint-disable-next-line no-unused-vars
const SampleCard = ({ sampleId, setSampleId, setSampleTypeId, setCollectionId, setCollectionTypeId }) => {
  const classes = useStyles();
  const history = useHistory();

  const [sample, setSample] = useState();
  const [inventory, setInventory] = useState([]);
  // const [items, setItems] = useState([1,2,3]);
  // TODO: change this from true / false to show / hide
  const [showDeleted, setShowDeleted] = useState(false);

  // add item
  // const [itemAdd, setItemAdd] = useState(0);

  const handleChange = async () => {
    setShowDeleted(!showDeleted);
  };

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
    const response1 = await sampleAPI.getById(id);
    const response2 = await objectsAPI.getBySample(id);
    if (!response1) return;

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

  const handleContainerClick = async (id) => {
    event.preventDefault();
    alert(id)
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

  return (
    <>

      <Typography>
        <p className={classes.right}>
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
              <div className={classes.relative}>
                  <img src='/beaker.png' className={classes.logoImage}/>
                  <div className={classes.logoText}>
                    <div className={classes.textTitle}>
                      {sample.sample_type}
                    </div>
                    <div className={classes.mb4}>
                      <span className={classes.textBold}>ID #</span>
                      {' '}
                      <span className={classes.textInfo}>{sample.id}</span>
                    </div>
                    <div className={classes.mb4}>
                      <span className={classes.textBold}>Added by</span>
                      {' '}
                      <span className={classes.textInfo}>{sample.user_name}</span>
                    </div>
                  </div>

                  <Divider />

                  <div className={classes.flexCardLabel}>
                    Name
                  </div>
                  <div className={classes.flexCardText}>
                    {sample.name || '-'}
                  </div>

                  <div className={classes.flexCardLabel}>
                    Description
                  </div>
                  <div className={classes.flexCardText}>
                    {sample.description || '---'}
                  </div>

                  {sample.fields.map((k) => (
                    <>
                      <div className={classes.flexCardLabel}>
                        {k.name}
                      </div>
                      <div className={classes.flexCardText}>
                        {k.value || <span>---</span>}
                      </div>
                    </>
                  ))}

                  {sample.fields_urls.map((k) => (
                    <>
                      <div className={classes.flexCardLabel}>
                        {k.name}
                      </div>
                      <div className={classes.flexCardText}>
                        {k.value ? <Link className={classes.pointer} onClick={() => window.open(k.value, "_blank")}>{k.value}</Link> : <span>---</span>}
                      </div>
                    </>
                  ))}

                  <Divider />

                  {sample.fields_samples.map((k) => (
                    <>
                      <div className={classes.flexCardLabel}>
                        {k.name}
                      </div>
                      <div className={classes.flexCardText}>
                        {k.child_sample_id ? <Link className={classes.pointer} onClick={() => handleClick(k.child_sample_id)}>{k.child_sample_id}: {k.child_sample_name}</Link> : <span>---</span>}
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
            <div className={classes.flexWrapper}>
              <div className={`${classes.flex} ${classes.flexTitle}`}>
                <Typography className={`${classes.flexColFixed40} ${classes.center}`}>
                  <b>+</b>
                </Typography>
                <Typography className={classes.flexCol4}>
                  <b>Object Type</b>
                </Typography>
                <Typography className={`${classes.flexCol1} ${classes.right}`}>
                  <b>In Inventory</b>
                </Typography>
                <Typography className={`${classes.flexCol1} ${classes.right}`}>
                  <b>Discarded</b>
                </Typography>
                <Typography className={`${classes.flexColFixed40} ${classes.center} ${classes.hidden}`}>
                  &nbsp;
                </Typography>
                <Typography className={`${classes.flexCol1} ${classes.mtm7} ${classes.relative}`}>
                  <Typography className={`${classes.absolute} ${classes.hide}`}>
                    <FormGroup className={ Object.values(toggleIds).indexOf(true) == -1 ? classes.hide : classes.show }>
                      <FormControlLabel
                        control={<Switch checked={showDeleted} onChange={handleChange} />}
                        label={<span style={{ fontSize: '13px' }}>{showDeleted ? 'Hide' : 'Show'}</span>}
                      />
                    </FormGroup>
                  </Typography>
                </Typography>
              </div>

              <div className={classes.flexBottom}>
                {inventory.map((group,index) => (
                  <>
                    <div className={`${classes.flex} ${toggleIds[index] ? classes.flexRowSel : classes.flexRow}`}  key={`index_${index}`}>
                      <Typography className={`${classes.flexColFixed40} ${classes.center} ${classes.pointer_no_hover}`} onClick={() => handleToggles(index)}>
                        &#x2195;
                      </Typography>
                      <Typography className={`${classes.flexCol4} ${classes.pointer_no_hover}`} onClick={() => handleToggles(index)} cy={`group-${group.type_id}`}>
                        {group.type}
                      </Typography>
                      <Typography className={`${classes.flexCol1} ${classes.right} ${classes.pointer_no_hover}`} onClick={() => handleToggles(index)}>
                        {group.count_inventory}
                      </Typography>
                      <Typography className={`${classes.flexCol1} ${classes.right} ${classes.pointer_no_hover}`} onClick={() => handleToggles(index)}>
                        {group.count_deleted}
                      </Typography>
                      <Typography className={`${classes.flexColFixed40} ${classes.center} ${classes.hidden}`}>
                        &nbsp;
                      </Typography>
                      <Typography className={`${classes.flexCol1} ${classes.mtm8} ${classes.relative}`}>
                        <Typography className={`${classes.absolute}`}>
                          <FormGroup className={ toggleIds[index] ? classes.show : classes.hide }>
                            <FormControlLabel
                              control={<Switch onChange={handleToggle} name={`checked_${index}`} />}
                              label={<span style={{ fontSize: '13px' }}>Discarded</span>}
                              cy={`toggle-${group.type_id}`}
                            />
                          </FormGroup>
                        </Typography>
                      </Typography>
                    </div>

                    <div className={toggleIds[index] ? classes.show : classes.hide}>
                      <div className={`${classes.flex} ${classes.flexTitleSub}`}>
                        <div className={`${classes.flexColFixed40} ${classes.center}`}>
                          &nbsp;
                        </div>
                        <div className={classes.flexCol1}>
                          Item #
                        </div>
                        <div className={classes.flexCol1}>
                          Location
                        </div>
                        <div className={`${classes.flexCol1} ${classes.right}`}>
                          Added
                        </div>
                        <div className={classes.flexColAuto}>
                          <span className={classes.hidden}>&#128465;</span>
                        </div>
                      </div>

                      {group.data.map((item) => (
                        <div className = {item.location == 'deleted' ? ( state[`checked_${index}`] ? classes.show : classes.hide ) : ''}>
                          <div className={`${classes.flex} ${classes.flexRowSub}`}>
                            <div className={`${classes.flexColFixed40} ${classes.center}`}>
                              &nbsp;
                            </div>
                            <div className={classes.flexCol1} cy={`item-${item.item_id}`}>
                              {item.collections ? (
                                <>
                                  <Link className={classes.pointer} onClick={() => handleCollectionClick(item.item_id, item.type_id)}>{item.item_id}</Link>
                                  {item.collections.map((part) => (
                                    <div>
                                      &rarr; {part.part_id} [{part.row}, {part.column}]
                                    </div>
                                  ))}
                                </>
                              ) : (
                                <Link className={classes.pointer} onClick={() => handleContainerClick(item.item_id)}>{item.item_id}</Link>
                              )}
                            </div>
                            <div className={classes.flexCol1}>
                              {item.location}
                            </div>
                            <div className={`${classes.flexCol1} ${classes.right}`}>
                              {item.date.substr(0,10)}
                            </div>
                            <div className={classes.flexColAuto}>
                              <span className={item.location == 'deleted' ? classes.hidden : classes.visible}>&#128465;</span>
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
                  <MenuItem key={objectType.id} value={objectType.id}>{objectType.name}</MenuItem>
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
