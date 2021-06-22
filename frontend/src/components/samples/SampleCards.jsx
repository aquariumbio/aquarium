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
import samplesAPI from '../../helpers/api/samplesAPI';
import usersAPI from '../../helpers/api/usersAPI';
import objectsAPI from '../../helpers/api/objectsAPI';
import SampleCard from './SampleCard';
import globalUseSyles from '../../globalUseStyles';

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

  mb16: {
    marginBottom: '16px',
  },

  textBold: {
    fontWeight: 'bold',
  },

  textInfo: {
    color: '#808080',
  },
}));

// eslint-disable-next-line no-unused-vars
const SampleCards = ({ handlePage, handleClick, count, page, pages, samples }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();

  return (
    <>
      <div className={globalClasses.center}>
        <p>
          {count} Samples
        </p>
        <p>
          <span className={classes.mr16}>
            <button className={`${globalClasses.pointer} ${page == 1 ? globalClasses.hidden : globalClasses.visible}`} onClick={() => handlePage(1)}>First</button>
          </span>
          <span className={classes.mr16}>
            <button className={`${globalClasses.pointer} ${page == 1 ? globalClasses.hidden : globalClasses.visible}`} onClick={() => handlePage(page-1)}>&lt; Prev</button>
          </span>
          <span className={`${classes.width200} ${pages == 0 ? globalClasses.hidden : globalClasses.visible}`}>
            Page {page} of {pages}
          </span>
          <span className={classes.ml16}>
            <button className={`${globalClasses.pointer} ${page >= pages ? globalClasses.hidden : globalClasses.visible}`} onClick={() => handlePage(page+1)}>Next ></button>
          </span>
          <span className={classes.ml16}>
            <button className={`${globalClasses.pointer} ${page >= pages ? globalClasses.hidden : globalClasses.visible}`} onClick={() => handlePage(pages)}>Last</button>
          </span>
        </p>
      </div>

      <div className={classes.flexCardWrapper}>
        <div className={globalClasses.flex}>
          {samples.map((sample) => (
            <div className={classes.flexCard25} cy={`sample-${sample.id}`}>
              <div className={classes.cardScroll}>
                <img src='/beaker.png' className={classes.logoImage}/>
                <Link cy={`sample.${sample.id}`} className={classes.logoPopout} onClick={() => handleClick(sample.id)}>&#x2197;</Link>
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
            </div>
          ))}
        </div>
      </div>
    </>
  );
};

SampleCards.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes,
};

export default SampleCards;
