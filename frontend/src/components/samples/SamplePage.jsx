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

import { StandardButton } from '../shared/Buttons';
import sampleAPI from '../../helpers/api/sample';

// Route: /object_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles(() => ({
  box: {
    margin: '24px',
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
    '&:hover': {
      backgroundColor: '#eee',
    },
  },

  flexRowSel: {
    padding: '8px 0',
    borderTop: '1px solid #ccc',
    borderLeft: '1px solid  #ccc',
    borderRight: '1px solid  #ccc',
    backgroundColor: '#d6e9ff',
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
    paddingRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexColFixed40: {
    width: '40px',
    paddingRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  /* Use to scale and hide columns in the title row */
  flexColAutoHidden: {
    width: 'auto',
    paddingRight: '8px',
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
    marginRight: '1.5%',
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

  wrapper: {
    padding: '0 24px',
  },

  logoImage: {
    position: 'absolute',
  },

  logoText: {
    marginLeft: '40px',
    lineHeight: '30px',
    fontSize: '18px',
  },

  logoSubText: {
    marginLeft: '40px',
    lineHeight: '10px',
    fontSize: '12px',
    color: '#aaa',
    marginBottom: '16px',
  },

  string: {
    color: '#358235',
  },

  number: {
    color: '#358235',
  },

  url: {
    color: '#966306',
  },

  sample: {
    color: '#353582',
  },

  info: {
    color: '#aaa',
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

// change the state of toggleIds[index] and trigger React to update the screen
// (see NOTE below)
const handleToggles = (id, toggleIds, setToggleIds, triggerUpdate) => {
  const newIds = toggleIds;
  newIds[id] = !newIds[id];
  setToggleIds(newIds);
  triggerUpdate();
};

// eslint-disable-next-line no-unused-vars
const SamplePage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const history = useHistory();

  const id = match.params.id;
  const [sample, setSample] = useState();
  const [inventory, setInventory] = useState([]);
  const [items, setItems] = useState([1,2,3]);
  // TODO: change this from true / false to show / hide
  const [showDeleted, setShowDeleted] = useState(false);

  const handleChange = async () => {
    setShowDeleted(!showDeleted);
  };

  const [state, setState] = React.useState({
  });

  const handleToggle = (event) => {
    setState({ ...state, [event.target.name]: event.target.checked });
  };

  // NOTE: regarding toggleIds and triggerUpdate
  // eslint-disable-next-line max-len
  // toggleIds used to track show/hide state for object type details, takes the form { index => true/false }
  // triggerUpdate used to trigger a screen update.
  // - React does not change the screen when changing the toggleIds
  //   eslint-disable-next-line max-len
  // - calling triggerUpdate() triggers a screen update (which also includes any state changes to toggleIds)
  const [toggleIds, setToggleIds] = useState({});
  // eslint-disable-next-line arrow-parens
  const [, triggerUpdate] = useReducer(x => !x, false);

  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await sampleAPI.getById(id);
      if (!response) return;

      // success
      setSample(response.sample);
      setInventory(response.inventory);
    };

    init();
  }, []);

  return (
    <div className={`${classes.wrapper} ${classes.mt8}`}>
      <div className={classes.header}>
        <Typography className={`${classes.searchBox} ${classes.mr24}`}>
          Sample: {sample ? sample.name : ''}
        </Typography>

        <Typography>
          <StandardButton
            name="Back"
            testName="back"
            text="Back"
            type="button"
            handleClick = {() => {history.goBack()}}
          />
        </Typography>
      </div>

      <Divider />

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
                  {sample.sample_type}
                </div>
                <div className={classes.logoSubText}>
                  {sample.user_name} ({sample.login})
                </div>
                <div className={classes.flexCardLabel}>
                  NAME
                </div>
                <div className={classes.flexCardText}>
                  {sample.name || <span className={classes.info}>-</span>}
                </div>

                <div className={classes.flexCardLabel}>
                  DESCRIPTION
                </div>
                <div className={classes.flexCardText}>
                  {sample.description || <span className={classes.info}>-</span>}
                </div>

                {sample.fields.map((k) => (
                  <>
                    <div className={`${classes.flexCardLabel} ${classes[`${k.type}`]}`}>
                      {k.name}
                    </div>
                    <div className={classes.flexCardText}>
                      { /* TODO: THIS IS REALLY UGLY... */ }
                      {k.value || (k.child_sample_id ? <span>{k.child_sample_id}: {k.child_sample_name}</span> : <span className={classes.info}>-</span>)}
                    </div>
                  </>
                ))}

                <div className={classes.flexCardLabel}>
                  Items
                </div>
                <div className={`{classes.flexCardText} {classes.mt8}`}>
                  {sample.item_ids.map((k) => (
                    <div>{k}</div>
                  ))}
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
                    <Typography className={`${classes.flexColFixed40} ${classes.center} ${classes.pointer_no_hover}`} onClick={() => handleToggles(index, toggleIds, setToggleIds, triggerUpdate)}>
                      &#x2195;
                    </Typography>
                    <Typography className={`${classes.flexCol4} ${classes.pointer_no_hover}`} onClick={() => handleToggles(index, toggleIds, setToggleIds, triggerUpdate)} cy={`group-${group.type_id}`}>
                      {group.type}
                    </Typography>
                    <Typography className={`${classes.flexCol1} ${classes.right} ${classes.pointer_no_hover}`} onClick={() => handleToggles(index, toggleIds, setToggleIds, triggerUpdate)}>
                      {group.count_inventory}
                    </Typography>
                    <Typography className={`${classes.flexCol1} ${classes.right} ${classes.pointer_no_hover}`} onClick={() => handleToggles(index, toggleIds, setToggleIds, triggerUpdate)}>
                      {group.count_deleted}
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
                    {group.data.map((item) => (
                      <div className = {item.location == 'deleted' ? ( state[`checked_${index}`] ? classes.show : classes.hide ) : ''}>
                      <div className={`${classes.flex} ${classes.flexRowSub}`}>
                        <div className={`${classes.flexColFixed40} ${classes.center}`}>
                          &nbsp;
                        </div>
                        <div className={classes.flexCol1} cy={`item-${item.item_id}`}>
                          {item.item_id}
                        </div>
                        <div className={classes.flexCol1}>
                          {item.location}
                        </div>
                        <div className={classes.flexCol4}>
                          {item.collections ? (
                            <div>
                              collection:
                              {item.collections.map((collection) => (
                                <>
                                 {' '}[{collection.row},{collection.column}]
                                </>
                              ))}
                            </div>
                          ) : (
                            ''
                          )}
                          {item.key_values ? (
                            item.key_values.map((kv) => (
                              <div>
                               <b>{kv.key}</b>:{' '}
                               {kv.upload_id ? kv.upload_file_name : (typeof JSON.parse(kv.object)[`${kv.key}`] == "object" ? JSON.stringify(JSON.parse(kv.object)[`${kv.key}`]) : JSON.parse(kv.object)[`${kv.key}`]) }
                              </div>
                            ))
                          ) : (
                            ''
                          )}
                        </div>
                        <div className={classes.flexCol1}>
                          {item.date.substr(0,10)}
                        </div>
                        </div>
                      </div>
                    ))}
                  </div>
                  </>
                ))}
                </div>

            </div>
          </Grid>
        </Grid>
      </div>
    </div>
  );
};

SamplePage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default SamplePage;
