/* eslint-disable react/forbid-prop-types */
import React, { useState } from 'react';
import Grid from '@material-ui/core/Grid';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core';
import samplesAPI from '../../helpers/api/samplesAPI';

const useStyles = makeStyles(() => ({
  root: {
    height: '100%',
    overflowY: 'scroll',
  },
}));
const SideBar = ({ sampleTypes, setCurrentSampleType, setIsLoading }) => {
  const classes = useStyles();

  const [selectedIndex, setSelectedIndex] = useState(0);

  const fetchData = async (id) => {
    // loading overlay - delay by 300ms to avoid screen flash
    const loading = setTimeout(() => {
      setIsLoading(true);
    }, window.$timeout);

    const response = await samplesAPI.getTypeById(id);

    // break if the HTTP call resulted in an error ("return false" from API.js)
    if (!response) {
      return;
    }

    // clear timeout and clear overlay
    clearTimeout(loading);
    setIsLoading(false);

    // success
    setCurrentSampleType(response);
  };

  const handleListItemClick = (event, index, id) => {
    fetchData(id);
    setSelectedIndex(index);
    window.scrollTo(0, 0);
  };

  return (
    <Grid
      item
      xs={2}
      name="sample-types-side-bar"
      data-cy="sample-types-side-bar"
      className={classes.root}
    >
      <List component="nav" aria-label="sample types list">
        {sampleTypes.map((st, index) => (
          <ListItem
            button
            key={st.id}
            selected={selectedIndex === index}
            onClick={(event) => handleListItemClick(event, index, st.id)}
          >
            <ListItemText primary={st.name} primaryTypographyProps={{ noWrap: true }} />
          </ListItem>
        ))}
      </List>
    </Grid>
  );
};

export default SideBar;

SideBar.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  sampleTypes: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      object_types: PropTypes.object,
      inventory: PropTypes.number,
      field_types: PropTypes.object,
    })
  ).isRequired,
  setCurrentSampleType: PropTypes.func.isRequired,
};
