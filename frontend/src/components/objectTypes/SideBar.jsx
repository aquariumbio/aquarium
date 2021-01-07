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
import objectsAPI from '../../helpers/api/objects';

const useStyles = makeStyles(() => ({
  root: {
    height: '100%',
    overflowY: 'scroll',
  },
}));
const SideBar = ({ objectTypeHandlers, setCurrentObjectTypeHandler, setCurrentObjectTypesByHandler }) => {
  const classes = useStyles();

  const [selectedIndex, setSelectedIndex] = useState(0);

  const fetchData = async (handler) => {
    const response = await objectsAPI.getByHandler(handler);

    // break if the HTTP call resulted in an error ("return false" from API.js)
    // NOTE: the alert("break") is just there for testing. Whatever processing should be handled in API.js, and we just need stop the system from trying to continue...
    if (!response) {
      alert("break")
      return;
    }

    // success
    setCurrentObjectTypeHandler(handler);
    setCurrentObjectTypesByHandler(response[handler]["object_types"]);
  };

  const handleListItemClick = (event, index, handler) => {
    fetchData(handler);
    setSelectedIndex(index);
    window.scrollTo(0, 0);
  };

  return (
    <Grid
      item
      xs={2}
      name="object-types-side-bar"
      data-cy="object-types-side-bar"
      className={classes.root}
    >
      <Card>
        <CardContent>
          <List component="nav" aria-label="object types list">
            {objectTypeHandlers.map((st, index) => (
              <ListItem
                button
                key={st.handler}
                selected={selectedIndex === index}
                onClick={(event) => handleListItemClick(event, index, st.handler)}
              >
                <ListItemText primary={st.handler} primaryTypographyProps={{ noWrap: true }} />
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
  objectTypeHandlers: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      handler: PropTypes.string,
    }),
  ).isRequired,
  setCurrentObjectTypeHandler: PropTypes.func.isRequired,
};
