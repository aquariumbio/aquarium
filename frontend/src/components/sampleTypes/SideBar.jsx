/* eslint-disable react/forbid-prop-types */
import React, { useState } from 'react';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Grid from '@material-ui/core/Grid';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core';
import API from '../../helpers/API';

const useStyles = makeStyles(() => ({
  root: {
    height: '100%',
    overflowY: 'scroll',
  },
}));
const SideBar = ({ sampleTypes, setCurrentSampleType }) => {
  // eslint-disable-next-line no-console
  console.log(window.innerHeight);
  const classes = useStyles();

  const [selectedIndex, setSelectedIndex] = useState(0);

  const fetchData = async (id) => {
    const data = await API.samples.getTypeById(id);
    setCurrentSampleType(data);
  };

  const handleListItemClick = (event, index, id) => {
    fetchData(id);
    setSelectedIndex(index);
    window.scrollTo(0, 0);
  };

  return (
    <Grid item xs={2} name="sample-types-side-bar" data-cy="sample-types-side-bar" className={classes.root}>
      <Card>
        <CardContent>
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
        </CardContent>
      </Card>
    </Grid>
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
