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
import samplesAPI from '../../helpers/api/samplesAPI';
import objectsAPI from '../../helpers/api/objectsAPI';

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
const SampleForm = ({ sampleId, sampleTypeId, setSampleTypeId }) => {
  const classes = useStyles();
  const history = useHistory();

  const [sampleType, setSampleType] = useState({});
  const [sample, setSample] = useState({});

  useEffect(() => {
    const init = async () => {
      // wrap the API calls
      const response = await samplesAPI.getTypeById(sampleTypeId);
      if (!response) return;

      // success
      setSampleType(response);
    };

    const initEdit = async (id) => {
      // wrap the API calls
      const response = await sampleAPI.getById(id);
      if (!response) return;

      // success
      setSample(response.sample)
    }

    init();
    sampleId == 0 ? '' : initEdit(sampleId);
  }, []);

  return (
    <>

      <Typography>
        <p className={classes.right}>
          <Button variant="outlined" onClick={() => {setSampleTypeId(0)}}>Close</Button>
        </p>
      </Typography>

      <div className={classes.box}>
        <Typography>
          {sampleType.name} ({sample.id})
        </Typography>

        <div className={classes.flexBottom}>
        <div className={`${classes.flex} ${classes.flexRow}`}>
          <Typography className={classes.flexCol1}>
            (*) name
          </Typography>
          <Typography className={classes.flexCol1}>
            (string)
          </Typography>
          <Typography className={classes.flexCol3}>
            <input
            value={sample.name}
            />
          </Typography>
        </div>

        <div className={`${classes.flex} ${classes.flexRow}`}>
          <Typography className={classes.flexCol1}>
            description
          </Typography>
          <Typography className={classes.flexCol1}>
            (string)
          </Typography>
          <Typography className={classes.flexCol3}>
            <input
            value={sample.description}
            />
          </Typography>
        </div>

        <div className={`${classes.flex} ${classes.flexRow}`}>
          <Typography className={classes.flexCol1}>
            (*) project
          </Typography>
          <Typography className={classes.flexCol1}>
            (string)
          </Typography>
          <Typography className={classes.flexCol3}>
            <input
            value={sample.project}
            />
          </Typography>
        </div>

        {sampleType.field_types && sampleType.field_types.map((field_type) => (
          <div className={`${classes.flex} ${classes.flexRow}`}>
            <Typography className={classes.flexCol1}>
              {field_type.required ? '(*)' : ''} {field_type.name}

            </Typography>
            <Typography className={classes.flexCol1}>
              ({field_type.ftype}{field_type.array ? ' / array' : ''}) <br />
              {field_type.ftype == 'sample' && field_type.allowable_field_types ? (
                <>
                    {field_type.allowable_field_types.map((allowable_field_type) => (
                      <>
                        {allowable_field_type.name} <br />
                      </>
                    ))}
                </>
              ) : (
                ''
              )}
            </Typography>
            <Typography className={classes.flexCol3}>
              <input />
            </Typography>
          </div>
        ))}
        </div>
      </div>
    </>

  );
};

SampleForm.propTypes = {
  sampleId: PropTypes.isRequired,
};

export default SampleForm;
