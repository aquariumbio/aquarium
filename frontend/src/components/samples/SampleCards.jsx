import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import Divider from '@material-ui/core/Divider';
import Toolbar from '@material-ui/core/Toolbar';
import Link from '@material-ui/core/Link';

import { StandardButton } from '../shared/Buttons';
import sampleAPI from '../../helpers/api/sampleAPI';
import usersAPI from '../../helpers/api/usersAPI';
import objectsAPI from '../../helpers/api/objectsAPI';
import SampleCard from './SampleCard';

// Route: /object_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles(() => ({
  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  subheader: {
    display: 'flex',
    alignItems: 'center',
  },

  /* flex */
  flexCardWrapper: {
    margin: '0 -1.5%',
  },

  flex: {
    display: '-ms-flexbox',
    // eslint-disable-next-line no-dupe-keys
    display: 'flex',
    position: 'relative',
    flexFlow: 'wrap',
  },

  flexCard25: {
    flex: '0 0 22%',
    marginRight: '1.5%',
    marginLeft: '1.5%',
    minWidth: '0',
    border: '1px solid black',
    marginBottom: '40px',
    fontSize: '14px',
  },

  cardScroll: {
    padding: '8px',
    height: '400px',
    overflowY: 'scroll',
    position: 'relative',
  },

  cardStatusBar: {
    overflowY: 'scroll',
    padding: '4px 8px',
  },

  flexCardLabel: {
    fontWeight: 'bold',
    wordBreak: 'break-all',
  },

  flexCardText: {
    marginBottom: '16px',
    wordBreak: 'break-all',
    color: '#333',
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

  pointer: {
    cursor: 'pointer',
  },

  absolute: {
    position: 'absolute',
  },

  searchBox: {
    width: '600px',
    marginRight: '24px',
  },

  width200: {
    width: '160px',
    display: 'inline-block',
    textAlign: 'center',
  },

  ml16: {
    marginLeft: '16px',
  },

  mr16: {
    marginRight: '16px',
  },

  mr24: {
    marginRight: '24px',
  },

  mt16: {
    marginTop: '16px',
  },

  center: {
    textAlign: 'center',
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

  textBold: {
    fontWeight: 'bold',
  },

  textInfo: {
    color: '#333',
  },
}));

// eslint-disable-next-line no-unused-vars
const SamplesPage = ({ handlePage, handleClick, count, page, pages, samples }) => {
  const classes = useStyles();

  return (
    <>
      <Typography>
        <p>
          <div className={classes.absolute}>
            {count} Samples
          </div>

          <div className={classes.center}>
            <span className={classes.mr16}>
              <button className={`${classes.pointer} ${page == 1 ? classes.hidden : classes.visible}`} onClick={() => handlePage(1)}>First</button>
            </span>
            <span className={classes.mr16}>
              <button className={`${classes.pointer} ${page == 1 ? classes.hidden : classes.visible}`} onClick={() => handlePage(page-1)}>&lt; Prev</button>
            </span>
            <span className={`${classes.width200} ${pages == 0 ? classes.hidden : classes.visible}`}>
              Page {page} of {pages}
            </span>
            <span className={classes.ml16}>
              <button className={`${classes.pointer} ${page >= pages ? classes.hidden : classes.visible}`} onClick={() => handlePage(page+1)}>Next ></button>
            </span>
            <span className={classes.ml16}>
              <button className={`${classes.pointer} ${page >= pages ? classes.hidden : classes.visible}`} onClick={() => handlePage(pages)}>Last</button>
            </span>
          </div>
        </p>
      </Typography>

      <div className={classes.flexCardWrapper}>
        <div className={classes.flex}>
          {samples.map((sample) => (
            <div className={classes.flexCard25} cy={`sample-${sample.id}`}>
              <div className={classes.cardScroll}>
                <img src='/beaker.png' className={classes.logoImage}/>
                <Link className={classes.logoPopout} onClick={() => handleClick(sample.id)}>&#x2197;</Link>
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
                  {sample.description || '-'}
                </div>

                {sample.fields.map((k) => (
                  <>
                    <div className={classes.flexCardLabel}>
                      {k.name}
                    </div>
                    <div className={classes.flexCardText}>
                      {k.value || <span>-</span>}
                    </div>
                  </>
                ))}

                {sample.fields_urls.map((k) => (
                  <>
                    <div className={classes.flexCardLabel}>
                      {k.name}
                    </div>
                    <div className={classes.flexCardText}>
                      {k.value ? <Link className={classes.pointer} onClick={() => window.open(k.value, "_blank")}>{k.value}</Link> : <span>-</span>}
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
                      {k.child_sample_id ? <Link className={classes.pointer} onClick={() => handleClick(k.child_sample_id)}>{k.child_sample_id}: {k.child_sample_name}</Link> : <span>-</span>}
                    </div>
                  </>
                ))}

                <div className={classes.mb16}>
                  <span className={classes.textBold}>Added:</span>
                  {' '}
                  <span className={classes.textInfo}>{sample.created_at.substr(0,10)}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  );
};

SamplesPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes,
};

export default SamplesPage;
