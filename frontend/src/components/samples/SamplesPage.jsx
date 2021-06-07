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
import sampleAPI from '../../helpers/api/sample';
import usersAPI from '../../helpers/api/users';
import objectsAPI from '../../helpers/api/objects';
import SampleOverlay from './SampleOverlay';

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
const SamplesPage = ({ setIsLoading, setAlertProps }) => {
  const classes = useStyles();

  const [showSample,setShowSample] = useState(false);

  const [samples, setSamples] = useState([]);
  const [count, setCount] = useState();
  const [page, setPage] = useState();
  const [pages, setPages] = useState();
  const [user, setUser] = useState({});

  const [search, setSearch] = useState('');
  // initialize searchWords as single space so it triggers the search on page load
  const [searchWords, setSearchWords] = useState(' ');
  // sample types for search by sample type + add sample dropdowns
  const [sampleTypes, setSampleTypes] = useState([]);
  // search by sample type id
  const [sampleTypeId, setSampleTypeId] = useState(0);
  // search by created by id
  const [createdById, setCreatedById] = useState(0);

  // add sample
  const [sampleAdd, setSampleAdd] = useState(0);
  // collection types
  const [collectionTypes, setCollectionTypes] = useState([]);
  // add collection
  const [collectionAdd, setCollectionAdd] = useState(0);

  const goSearch = async (sampletypeid, createdbyid, pagenum) => {
    const words = search.replace(/ +/g,' ') //.trim()

    if (words != searchWords || sampletypeid != sampleTypeId || createdbyid != createdById || pagenum != page) {
      if (words != searchWords || sampletypeid != sampleTypeId || createdbyid != createdById) pagenum = 1
      setSearchWords(words);
      setSampleTypeId(sampletypeid);
      setCreatedById(createdbyid);
      setPage(pagenum);

      // wrap the API call with the spinner
      const loading = setTimeout(() => { setIsLoading(true); }, window.$timeout);
      const response = await sampleAPI.getSamples(words, sampletypeid, createdbyid, pagenum);
      clearTimeout(loading);
      setIsLoading(false);
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
      // wrap the API calls
      const response1 = await sampleAPI.getTypes();
      const response2 = await objectsAPI.getByHandler('collection')
      if (!response1 || !response2) return;

      // success
      setUser(JSON.parse(localStorage.getItem('user')));
      setSampleTypes(response1.sample_types);
      setCollectionTypes(response2.collection.object_types);
    }

    goSearch(0, 0, 0);
    init();
  }, []);

  const handleAddcollection = async (id) => {
    setcollectionIdAdd(id)
    alert(`add collection ${id}`)
  }

  const handleAddSample = async (id) => {
    setSampleAdd(id)
    alert(`add sample ${id}`)
  }

  const handleAddCollection = async (id) => {
    setCollectionAdd(id)
    alert(`add collection ${id}`)
  }

  const handleClick = async (id) => {
    setShowSample(id)
  }

  const handleSampleTypeId = async (id) => {
    goSearch(id, createdById)
  }

  const handleCreatedById = async (id) => {
    goSearch(sampleTypeId, id)
  }

  return (
    <>
      <div className={classes.mt16}>
        <div className={`${classes.header} ${showSample ? classes.hidden : '' }`}>
          <div className={classes.subheader}>
            <Typography className={`${classes.searchBox} ${classes.mr24}`}>
              <TextField
                name="search"
                id="search"
                value = {search}
                placeholder="Search (e.g., by keyword, sample:123, item:123)"
                fullWidth
                onChange={(event) => setSearch(event.target.value)}
                variant="outlined"
                required
                type="string"
                inputProps={{
                  'aria-label': 'search',
                  'data-cy': 'search',
                }}
                onKeyUp = {(event) => goSearch(sampleTypeId, createdById)}
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
                <MenuItem value="0">All Sample Types</MenuItem>
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
                <MenuItem value="0">Added by anyone</MenuItem>
                <MenuItem value={user.id}>Added by me</MenuItem>
              </TextField>
            </Typography>
          </div>

          <div>
            <TextField
              name="add_sample"
              fullWidth
              id="add_sample"
              value={sampleAdd}
              onChange={(event) => handleAddSample(event.target.value)}
              variant="outlined"
              type="string"
              inputProps={{
                'aria-label': 'add_sample',
                'data-cy': 'add_sample',
              }}
              select
            >
              <MenuItem key="0" value="0">Add Sample</MenuItem>
              {sampleTypes.map((sampleType) => (
                <MenuItem key={sampleType.id} value={sampleType.id}>{sampleType.name}</MenuItem>
              ))}
            </TextField>
            <br /><br />

            <TextField
              name="add_collection"
              fullWidth
              id="add_collection"
              value={collectionAdd}
              onChange={(event) => handleAddCollection(event.target.value)}
              variant="outlined"
              type="string"
              inputProps={{
                'aria-label': 'add_collection',
                'data-cy': 'add_collection',
              }}
              select
            >
              <MenuItem key="0" value="0">Add Collection</MenuItem>
              {collectionTypes.map((collectionType) => (
                <MenuItem key={collectionType.id} value={collectionType.id}>{collectionType.name}</MenuItem>
              ))}
            </TextField>
          </div>
        </div>

        <Divider />

    {showSample ? (
      <SampleOverlay showSample={showSample} setShowSample={setShowSample}/>
    ) : (
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
              </div>
            ))}
          </div>
        </div>
      </>
    )}


      </div>
    </>
  );
};

SamplesPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes,
};

export default SamplesPage;
