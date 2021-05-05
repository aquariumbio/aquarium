import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import Divider from '@material-ui/core/Divider';
import Toolbar from '@material-ui/core/Toolbar';

import { StandardButton } from '../shared/Buttons';
import sampleAPI from '../../helpers/api/sample';
import usersAPI from '../../helpers/api/users';

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

  wrapper: {
    padding: '0 24px',
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

  mt8: {
    marginTop: '8px',
  },

  center: {
    textAlign: 'center',
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
}));

// eslint-disable-next-line no-unused-vars
const SamplesPage = ({ setIsLoading, setAlertProps }) => {
  const classes = useStyles();

  const [samples, setSamples] = useState([]);
  const [count, setCount] = useState();
  const [page, setPage] = useState();
  const [pages, setPages] = useState();

  const [search, setSearch] = useState('');
  // initialize searchWords as single space so it triggers the search on page load
  const [searchWords, setSearchWords] = useState(' ');
  const [sampleTypes, setSampleTypes] = useState([]);
  const [sampleTypeId, setSampleTypeId] = useState(0);
  const [createdBys, setCreatedBys] = useState([]);
  const [createdById, setCreatedById] = useState(0);
  const [sampleId, setSampleId] = useState(0);

  const goSearch = async (sampletypeid, createdbyid, sampleid, pagenum) => {
    const words = (' '+search+' ').replace(/ +/g,' ').replace(/ \S /g,' ').trim()
//     const newpage = (words != searchWords || sampletypeid != sampleTypeId || createdbyid != createdById) ? 1 : page

    if (words != searchWords || sampletypeid != sampleTypeId || createdbyid != createdById || pagenum != page) {
      if (words != searchWords || sampletypeid != sampleTypeId || createdbyid != createdById) pagenum = 1
      setSearchWords(words);
      setSampleTypeId(sampletypeid);
      setCreatedById(createdbyid);
      setSampleId(sampleid);
      setPage(pagenum);

      // wrap the API call
      const response = await sampleAPI.getSamples(words, sampletypeid, createdbyid, pagenum);
      if (!response) return;

      // success
      setCount(response.count);
      setPage(response.page);
      setPages(response.pages);
      setSamples(response.samples);
    }
  }

  const handlePage = async (pagenum) => {
    if (pagenum != page) {
      setPage(pagenum);

      const response = await sampleAPI.getSamples(searchWords, sampleTypeId, createdById, pagenum);
      if (!response) return;

      // success
      setCount(response.count);
      setPage(response.page);
      setPages(response.pages);
      setSamples(response.samples);
    }
  }

  useEffect(() => {
    const init = async () => {
      // wrap the API call
      const response = await sampleAPI.getTypes();
      if (!response) return;

      // success
      setSampleTypes(response.sample_types);

      // wrap the API call
      const responses = await usersAPI.getUsers();
      if (!responses) return;

      // success
      setCreatedBys(responses.users);
    }

    goSearch(0, 0, 0);
    init();
  }, []);

  const add = async () => {
    alert('add')
  }

  const handleClick = async (id) => {
    document.location.href = `/samples/${id}`
  }

  const handleSampleTypeId = async (id) => {
    goSearch(id, createdById, sampleId)
  }

  const handleCreatedById = async (id) => {
    goSearch(sampleTypeId, id, sampleId)
  }

  const handleSampleId = async (id) => {
    goSearch(sampleTypeId, createdById, id)
  }

  return (
    <div className={`${classes.wrapper} ${classes.mt8}`}>
      <div className={classes.header}>
        <div className={classes.subheader}>
          <Typography className={`${classes.searchBox} ${classes.mr24}`}>
            <TextField
              name="search"
              id="search"
              placeholder="Search"
              fullWidth
              onChange={(event) => setSearch(event.target.value)}
              variant="outlined"
              required
              type="string"
              inputProps={{
                'aria-label': 'search',
                'data-cy': 'search',
              }}
              onKeyUp = {(event) => goSearch(sampleTypeId, createdById, sampleId)}
            />
          </Typography>

          <Typography className={classes.mr24}>
            <TextField
              name="sample_type"
              id="sample-type"
              value={sampleTypeId}
              onChange={(event) => handleSampleTypeId(event.target.value)}
              variant="outlined"
              type="string"
              inputProps={{
                'aria-label': 'sample-type',
                'data-cy': 'sample-type',
              }}
              select
            >
              <MenuItem value="0"><span className={classes.info}>Sample Type... &nbsp;</span></MenuItem>
              {sampleTypes.map((sample) => (
                <MenuItem value={sample.id}>{sample.name}</MenuItem>
              ))}
            </TextField>
          </Typography>

          <Typography className={classes.mr24}>
            <TextField
              name="created_by"
              id="created-by"
              value={createdById}
              onChange={(event) => handleCreatedById(event.target.value)}
              variant="outlined"
              type="string"
              inputProps={{
                'aria-label': 'created-by',
                'data-cy': 'created-by',
              }}
              select
            >
              <MenuItem value="0"><span className={classes.info}>Created By... &nbsp;</span></MenuItem>
              {createdBys.map((by) => (
                <MenuItem value={by.id}>{by.name} ({by.login})</MenuItem>
              ))}
            </TextField>
          </Typography>
        </div>

        <Typography>
          <StandardButton
            name="Add"
            testName="add"
            text="Add"
            type="button"
            handleClick = {add}
          />
        </Typography>
      </div>

      <Divider />

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
            <span className={classes.width200}>
              Page {page} of {pages}
            </span>
            <span className={classes.ml16}>
              <button className={`${classes.pointer} ${page == pages ? classes.hidden : classes.visible}`} onClick={() => handlePage(page+1)}>Next ></button>
            </span>
            <span className={classes.ml16}>
              <button className={`${classes.pointer} ${page == pages ? classes.hidden : classes.visible}`} onClick={() => handlePage(pages)}>Last</button>
            </span>
          </div>
        </p>
      </Typography>


      <div className={classes.flexCardWrapper}>
        <div className={classes.flex}>
          {samples.map((sample) => (
            <div className={classes.flexCard25} onClick={() => handleClick(sample.id)}>
              <img src='/beaker.png' className={classes.logoImage}/>
              <div className={classes.logoText}>
                {sample.id}: {sample.sample_type}
              </div>
              <div className={classes.logoSubText}>
                {sample.user_name} ({sample.login})
              </div>
              <div className={classes.flexCardLabel}>
                NAME
              </div>
              <div className={classes.flexCardText}>
                {sample.name || '-'}
              </div>

              <div className={classes.flexCardLabel}>
                DESCRIPTION
              </div>
              <div className={classes.flexCardText}>
                {sample.description || '-'}
              </div>

              {sample.fields.map((k) => (
                <>
                  <div className={`${classes.flexCardLabel} ${classes[`${k.type}`]}`}>
                    {k.name}
                  </div>
                  <div className={classes.flexCardText}>
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
          ))}
        </div>
      </div>
    </div>
  );
};

SamplesPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes,
};

export default SamplesPage;
