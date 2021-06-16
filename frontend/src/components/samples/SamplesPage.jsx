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
import SampleCards from './SampleCards';
import SampleCard from './SampleCard';
import SampleForm from './SampleForm';
import CollectionForm from './CollectionForm';

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

  const [sampleId,setSampleId] = useState(0);
  const [collectionId,setCollectionId] = useState(0);
  const [containerId,setContainerId] = useState(0);

  const [samples, setSamples] = useState([]);
  const [count, setCount] = useState();
  const [page, setPage] = useState();
  const [pages, setPages] = useState();
  const [userId, setUserId] = useState();

  // search box
  const [search, setSearch] = useState('');
  // initialize searchWords as single space so it triggers the search on page load
  const [searchWords, setSearchWords] = useState(' ');
  // search by sample type id
  const [searchSampleTypeId, setSearchSampleTypeId] = useState(0);
  // search by created by id
  const [searchCreatedById, setSearchCreatedById] = useState(0);

  // list of sample types
  const [sampleTypes, setSampleTypes] = useState([]);
  // list of collection types
  const [collectionTypes, setCollectionTypes] = useState([]);

  // add/edit a sample by sample type id
  const [sampleTypeId, setSampleTypeId] = useState(0);
  // add/edit a collection by collection type id (an object type with handler = 'collection')
  const [collectionTypeId, setCollectionTypeId] = useState(0);
  // add/edit an item by object type id (an object type with handler = 'sample_container')
  const [containerTypeId, setContainerTypeId] = useState(0);

  const goSearch = async (sampletypeid, createdbyid, pagenum) => {
    const words = search.replace(/ +/g,' ') //.trim()

    if (words != searchWords || sampletypeid != searchSampleTypeId || createdbyid != searchCreatedById || pagenum != page) {
      if (words != searchWords || sampletypeid != searchSampleTypeId || createdbyid != searchCreatedById) pagenum = 1
      setSearchWords(words);
      setSearchSampleTypeId(sampletypeid);
      setSearchCreatedById(createdbyid);
      setPage(pagenum);

      // wrap the API call with the spinner
      const loading = setTimeout(() => { setIsLoading(true); }, window.$timeout);
      const response = await samplesAPI.getSamples(words, sampletypeid, createdbyid, pagenum);
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

      const response = await samplesAPI.getSamples(searchWords, searchSampleTypeId, searchCreatedById, pagenum);
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
      const response1 = await samplesAPI.getTypes();
      const response2 = await objectsAPI.getByHandler('collection')
      if (!response1 || !response2) return;

      // success
      setUserId(localStorage.getItem('userId'));
      setSampleTypes(response1.sample_types);
      setCollectionTypes(response2.collection.object_types);
    }

    goSearch(0, 0, 0);
    init();
  }, []);

  const handleAddSample = async (id) => {
    setSampleTypeId(id)
  }

  const handleAddCollection = async (id) => {
    setCollectionTypeId(id)
  }

  const handleClick = async (id) => {
    setSampleId(id)
  }

  const handleSampleTypeId = async (id) => {
    goSearch(id, searchCreatedById)
  }

  const handleCreatedById = async (id) => {
    goSearch(searchSampleTypeId, id)
  }

  return (
    <>
      <div className={classes.mt16}>
        <div className={`${classes.header} ${sampleId + sampleTypeId + collectionTypeId != 0 ? classes.hidden : '' }`}>
          <div className={classes.subheader}>
            <Typography className={`${classes.searchBox} ${classes.mr24}`}>
              <TextField
                name="search"
                id="search"
                value = {search}
                placeholder="Search ( by keyword / s:<sample_id> / i:<item_id> )"
                fullWidth
                onChange={(event) => setSearch(event.target.value)}
                variant="outlined"
                required
                type="string"
                inputProps={{
                  'aria-label': 'search',
                  'data-cy': 'search',
                }}
                onKeyUp = {(event) => goSearch(searchSampleTypeId, searchCreatedById)}
              />
            </Typography>

            <Typography className={classes.mr24}>
              <TextField
                name="sample_type"
                id="sample-type"
                value={searchSampleTypeId}
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
                value={searchCreatedById}
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
                <MenuItem value={userId}>Added by me</MenuItem>
              </TextField>
            </Typography>
          </div>

          <div className={classes.subheader}>
            <Typography className={classes.mr24}>
              <TextField
                name="add_sample"
                fullWidth
                id="add_sample"
                value={sampleTypeId}
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
            </Typography>

            <Typography className={classes.mr24}>
              <TextField
                name="add_collection"
                fullWidth
                id="add_collection"
                value={collectionTypeId}
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
            </Typography>
          </div>
        </div>
      </div>

      <Divider />

      {/* display one of
      sample pages
      - SampleCards (search page) <== sampleId == 0
      - SampleCard (individual sample page) <== sampleId != 0
      sub-forms
      - SampleForm (sample form) <== sampleTypeId != 0
      - ContainerForm (item form if item is a single item) <== containerTypeId != 0
      - Collectionform (item form if item is a collection) <== collectionTypeId != 0
      */}
      {sampleTypeId != 0 && (<SampleForm sampleId={sampleId} sampleTypeId={sampleTypeId} setSampleTypeId={setSampleTypeId}/>)}
      {/* {containerTypeId != 0 && (<ContainerForm containerId={containerId} containerTypeId={containerTypeId} setContainerTypeId={setContainerTypeId}/>)} */}
      {collectionTypeId != 0 && (<CollectionForm collectionId={collectionId} collectionTypeId={collectionTypeId} setCollectionTypeId={setCollectionTypeId}/>)}
      {sampleTypeId == 0 && collectionTypeId == 0 && sampleId != 0 && <SampleCard sampleId={sampleId} setSampleId={setSampleId} setSampleTypeId={setSampleTypeId} setCollectionId={setCollectionId} setCollectionTypeId={setCollectionTypeId}/>}
      {sampleTypeId == 0 && collectionTypeId == 0 && sampleId == 0 && <SampleCards handlePage={handlePage} handleClick={handleClick} count={count} page={page} pages={pages} samples={samples}/>}
    </>
  );
};

SamplesPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes,
};

export default SamplesPage;
