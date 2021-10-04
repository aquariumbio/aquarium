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
import sampleTypesAPI from '../../helpers/api/sampleTypesAPI';
import objectsAPI from '../../helpers/api/objectsAPI';

const useStyles = makeStyles(() => ({
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

  center: {
    textAlign: 'center',
  },

  right: {
    textAlign: 'right',
  },

  pointer: {
    cursor: 'pointer',
  },

  remove: {
    cursor: 'pointer',
    fontWeight: 'bold',
    fontSize: '150%',
    position: 'absolute',
    marginLeft: '8px',
    marginTop: '-4px',
  },

  add: {
    display: 'inline-block',
    cursor: 'pointer',
    border: '1px solid black',
    padding: '2px 4px',
    backgroundColor: '#eee',
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

  p100: {
    width: 'calc(100% - 80px)',
  },

  p100d: {
    width: 'calc(100% - 80px)',
    color: 'black',
    backgroundColor: 'transparent',
    border: '1px solid #777',
  },

  selectList: {
    maxHeight: '322px',
    overflowY: 'scroll',
    borderLeft: '1px solid #777',
    borderBottom: '1px solid #777',
    borderRight: '1px solid #777',
    marginRight: '80px',
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

  black: {
     color: 'black',
  },

}));

// eslint-disable-next-line no-unused-vars
const SampleForm = ({ setIsLoading, setAlertProps, sampleId, sampleTypeId, setSampleTypeId }) => {
  const classes = useStyles();
  const history = useHistory();

  const [sampleType, setSampleType] = useState({});
  const [sample, setSample] = useState({});
  // data values for fields
  const [fields, setFields] = useState({});
  // hash of allowable field types to pass to quicksearch { field_type_id: [<id>, <id>, ...] }
  const [allowableFieldTypes, setAllowableFieldTypes] = useState({});
  // hash of inputs
  const [inputs, setInputs] = useState({});
  // hash of lists for dropdown lists
  const [lists, setLists] = useState({})

  useEffect(() => {
    const init = async () => {
      // wrap the API calls
      const response = await sampleTypesAPI.getTypeById(sampleTypeId);
      if (!response) return;

      // success
      setSampleType(response);

      // initialize allowableFieldTypes {field_type_id: [<id>, <id>, ...]}
      let temp = new Object;
      response.field_types.map((f) => (
        f.ftype == 'sample' && (
          temp={...temp,[f.id]: []},
          f.allowable_field_types.map((a) =>
            temp[f.id]=[...temp[f.id], a.sample_type_id]
          )
        )
      ))
      setAllowableFieldTypes(temp)
    };

    const initEdit = async (id) => {
      // wrap the API calls
      const response = await samplesAPI.getById(id);
      if (!response) return;

      // success
      // map sample data
      const resp = response.sample
      let temp = new Object
      temp={...temp, ['id']: resp.id}
      temp={...temp, ['name']: resp.name}
      temp={...temp, ['description']: resp.description}
      temp={...temp, ['project']: resp.project}
      setSample(temp)

      // map fields to arrays {field_type_id: [<value>, <value>, ... ]}
      // for single items use fields[<id>][0]
      let temp2 = new Object
      resp.fields.map((f) => (
        f.type == 'sample' ? (
          f.child_sample_id && (
            temp2[f.id]
            ? temp2[f.id]=[...temp2[f.id],`${f.child_sample_id}: ${f.child_sample_name}`]
            : temp2[f.id]=[`${f.child_sample_id}: ${f.child_sample_name}`]
          )
        ) : (
          f.value && (
            temp2[f.id]
            ? temp2[f.id]=[...temp2[f.id], f.value]
            : temp2[f.id]=[f.value]
          )
        )
      ))
      setFields(temp2)
    }

    init();
    sampleId == 0 ? '' : initEdit(sampleId);
  }, []);

  const addField = async(id) => {
    let temp = fields[id]
    temp ? (
      temp=temp.push(''),
      setFields({...fields, [fields[id]]: temp})
    ) : (
      setFields({...fields, [id]: ['']})
    )
  }

  const editField = async(id, index, event) => {
    let temp = fields[id]
    temp ? (
      temp=temp.splice(index,1,event.target.value),
      setFields({...fields, [fields[id]]: temp})
    ) : (
      setFields({...fields, [id]: [temp]})
    )
  }

  const removeField = async(id,index) => {
    let temp = fields[id]
    temp = temp.splice(index,1)
    setFields({...fields, [fields[id]]: temp})
  }

  const handleInputs = async(event) => {
    setInputs({...inputs,
      [event.target.id]:event.target.value
    })
  }

  const handleChange = async(event) => {
    setSample({...sample,
      [event.target.name]: event.target.value
    })
  }

  // search for samples of type allowableFeildTypes
  const handleQuickSearch = async(id, event) => {
    setInputs({...inputs,
      [id]:event.target.value
    })

    const response1 = await samplesAPI.getQuickSearch(event.target.value,allowableFieldTypes[id].join('.'));
    if (!response1) return;

    // set item + object type
    setLists({...lists,[id]: response1});
  }

  // select an item from the list after searching
  // sets the fields variable to display the info and submit the form
  const handleSelect = async (id, event) => {
    setLists({...lists,[id]: []})
    setInputs({...inputs,
      [id]: ''
    })

    let temp = fields[id]
    temp ? (
      temp=temp.push(event.target.getAttribute('value')),
      setFields({...fields, [fields[id]]: temp})
    ) : (
      setFields({...fields, [id]: [event.target.getAttribute('value')]})
    )
  }

  // Submit form with all data
  const handleSubmit = async () => {
    // set formData
    const form = document.querySelector('#sampleForm');
    const data = new FormData(form);
    const formData = Object.fromEntries(data);

    // add the sample type id
    formData['sample_type_id'] = sampleTypeId

    // build sample inputs from names
    let inputsByName
    let temp
    sampleType.field_types.map((f) => (
      ( f.ftype == 'sample' || f.array ) && (
        temp = [],
        inputsByName = document.getElementsByName(`f.${f.id}`),
        inputsByName.forEach(i => temp.push(i.value)),
        formData[`f.${f.id}`]=temp
      )
    ))

    const response = sampleId == 0
      ? await samplesAPI.create(formData)
      : await samplesAPI.update(formData, sampleId);
    if (!response) return;

    // process errors
    const errors = response.errors;
    if (errors) {
      setAlertProps({
        message: JSON.stringify(errors, null, 2),
        severity: 'error',
        open: true,
      });
      return;
    }

    // success
    document.location.reload()

  }

  return (
    <form id='sampleForm'>

      <div className={classes.hidden}>
        <Button variant="outlined">&nbsp;</Button>
      </div>

      <div className={classes.box}>
        <Typography>
          {sampleType.name} ({sample.id})
        </Typography>

        <div className={classes.flexBottom}>
        <div className={`${classes.flex} ${classes.flexRow}`}>
          <Typography className={classes.flexCol1}>
            (*) name
          </Typography>
          <div className={classes.flexCol3}>
            <input
            className={classes.p100}
            name="name"
            value={sample.name}
            onChange={(event) => handleChange(event)}
            />
          </div>
        </div>

        <div className={`${classes.flex} ${classes.flexRow}`}>
          <Typography className={classes.flexCol1}>
            description
          </Typography>
          <div className={classes.flexCol3}>
            <input
            className={classes.p100}
            name="description"
            value={sample.description}
            onChange={(event) => handleChange(event)}
            />
          </div>
        </div>

        <div className={`${classes.flex} ${classes.flexRow}`}>
          <Typography className={classes.flexCol1}>
            (*) project
          </Typography>
          <div className={classes.flexCol3}>
            <input
            className={classes.p100}
            name="project"
            value={sample.project}
            onChange={(event) => handleChange(event)}
            />
          </div>
        </div>

        {sampleType.field_types && sampleType.field_types.map((field_type) => (
          <div className={`${classes.flex} ${classes.flexRow}`}>
            <Typography className={classes.flexCol1}>
              {field_type.required ? '(*)' : ''} {field_type.name} {field_type.array && '(array)'}
            </Typography>
            <div className={classes.flexCol3}>
              {/* TODO: maybe move to components to clean up */}
              {/* samples vs other inputs */}
              {/* arrays vs single inputs */}
              {/* choices vs unrestricted */}
              {field_type.ftype == 'sample' ? (
                <>
                  {fields[field_type.id] && (
                    fields[field_type.id].map((f,i) => (
                      <div className={classes.mb8}>
                        {/* NOTE: disabled inputs not in formData. Will build inputs from names */}
                        <input className={classes.p100d} disabled name={`f.${field_type.id}`} value={f} />
                        <span className={`${classes.remove}`} onClick={() => removeField(field_type.id, i)}>x</span>
                      </div>
                    ))
                  )}
                  {(field_type.array || !fields[field_type.id] || fields[field_type.id].length == 0) && (
                    <>
                      <div>
                        {/* NOTE: inputs with no name not in form data on purpose */}
                        <input className={classes.p100} placeholder="Add ( by name / s:<sample_id> )" value={inputs[`${field_type.id}`]} onChange={(event) => handleQuickSearch(field_type.id, event)} />
                      </div>
                      {lists[field_type.id] && lists[field_type.id].length!=0 && (
                        <div className={classes.selectList}>
                          {lists[field_type.id].map((l) => (
                            <div className={classes.selectItem} value={`${l.id}: ${l.name}`} onClick={(event) => handleSelect(field_type.id,event)}>
                              {l.id}: {l.name}
                            </div>
                          ))}
                        </div>
                      )}
                    </>
                  )}
                </>
              ) : (
                field_type.choices ? (
                  field_type.array ? (
                    <>
                      {fields[field_type.id] && (
                        fields[field_type.id].map((f,i) => (
                          <div className={classes.mb8}>
                            <select className={classes.p100d} name={`f.${field_type.id}`} value={f} onChange={(event) => editField(field_type.id, i, event)}>
                              {/* set the value equal to the option */}
                              {/* could also use the index but then have to map incoming data )*/}
                              <option value="">Select...</option>
                              {field_type.choices.split(",").map((c) =>
                                <option value={c}>{c}</option>
                              )}
                            </select>
                            <span className={`${classes.remove}`} onClick={() => removeField(field_type.id, i)}>x</span>
                          </div>
                        ))
                      )}
                      <Typography className={classes.add} onClick={(event) => addField(field_type.id)}>
                        Add
                      </Typography>
                    </>
                  ) : (
                    <select className={classes.p100d} name={`f.${field_type.id}`} value={fields[field_type.id] ? fields[field_type.id][0] : ''} onChange={(event) => editField(field_type.id, 0, event)}>
                      <option value="">Select...</option>
                      {/* set the value equal to the option */}
                      {/* could also use the index but then have to map incoming data )*/}
                      {field_type.choices.split(",").map((c) =>
                        <option value={c}>{c}</option>
                      )}
                    </select>
                  )
                ) : (
                  field_type.array ? (
                    <>
                      {fields[field_type.id] && (
                        fields[field_type.id].map((f,i) => (
                          <div className={classes.mb8}>
                            {/* NOTE: will build array from same names */}
                            <input className={classes.p100} name={`f.${field_type.id}`} value={fields[field_type.id][i]} onChange={(event) => editField(field_type.id, i, event)} />
                            <span className={`${classes.remove}`} onClick={() => removeField(field_type.id, i)}>x</span>
                          </div>
                        ))
                      )}
                      <Typography className={classes.add} onClick={(event) => addField(field_type.id)}>
                        Add
                      </Typography>
                    </>
                  ) : (
                    <div>
                      <input className={classes.p100} name={`f.${field_type.id}`} value={fields[field_type.id] ? fields[field_type.id][0] : ''} onChange={(event) => editField(field_type.id, 0, event)} />
                    </div>
                  )
                )
              )}
            </div>
          </div>
        ))}
        </div>
      </div>
      <div className={`${classes.right} ${classes.mb16}`}>
        <Button className={classes.mr16} variant="outlined" onClick={() => {setSampleTypeId(0)}}>Cancel</Button>
        <Button variant="outlined" onClick={handleSubmit}>Submit</Button>
      </div>
    </form>

  );
};

SampleForm.propTypes = {
  sampleId: PropTypes.isRequired,
};

export default SampleForm;

//             <div className={classes.flexCol1}>
//               <Typography>
//                 ({field_type.ftype} - {field_type.id}) <br />
//               </Typography>
//               {field_type.choices && (
//                 <Typography>
//                   {field_type.choices} <br />
//                 </Typography>
//               )}
//               {field_type.ftype == 'sample' && field_type.allowable_field_types && (
//                 <>
//                   {field_type.allowable_field_types.map((allowable_field_type) => (
//                     <Typography>
//                       {allowable_field_type.name}<br />
//                     </Typography>
//                   ))}
//                 </>
//               )}
//             </div>

