/* eslint-disable react/forbid-prop-types */
import React, { useState } from 'react';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import { makeStyles } from '@material-ui/core';
import PropTypes from 'prop-types';
import API from '../../helpers/API';

const useStyles = makeStyles((theme) => ({
  darkBtn: {
    backgroundColor: '#065683',
    color: 'white',
    margin: theme.spacing(3, 2),

    '& :hover': {
      backgroundColor: 'white',
      color: '#065683',
    },
  },

  lightBtn: {
    backgroundColor: 'white',
    color: '#065683',
    margin: theme.spacing(3, 2),

    '& :hover': {
      backgroundColor: '#065683',
      color: 'white',
    },
  },

  backdrop: {
    zIndex: theme.zIndex.drawer + 1,
    color: '#fff',
  },

  selected: {
    background: theme.secondary,
  },

}));
const SideBar = ({ sampleTypes, setCurrentSampleType }) => {
  const classes = useStyles();
  const [selectedIndex, setSelectedIndex] = useState(0);

  const fetchData = async (id) => {
    const data = await API.samples.getTypeById(id);
    setCurrentSampleType(data);
  };

  const handleListItemClick = (event, index, id) => {
    fetchData(id);
    setSelectedIndex(index);
  };

  return (
    <Card className={classes.root}>
      <CardContent>
        <List component="nav" aria-label="sample types list">
          {sampleTypes.map((st, index) => (
            <ListItem
              button
              key={st.id}
              selected={selectedIndex === index}
              onClick={(event) => handleListItemClick(event, index, st.id)}
            >
              <ListItemText primary={st.name} />
            </ListItem>
          ))}
        </List>
      </CardContent>
    </Card>
  );
};

export default SideBar;

SideBar.propTypes = {
  sampleTypes: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      object_types: PropTypes.object,
      inventory: PropTypes.number,
      field_types: PropTypes.object,
    }),
  ).isRequired,
  setCurrentSampleType: PropTypes.func.isRequired,
};
