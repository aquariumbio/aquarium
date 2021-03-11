// TODO: ADD PROP-TYPES
/* eslint-disable react/prop-types */
import React, { useState } from 'react';
import { withRouter } from 'react-router-dom';
import { makeStyles } from '@material-ui/core/styles';
import IconButton from '@material-ui/core/IconButton';
import Menu from '@material-ui/core/Menu';
import MenuItem from '@material-ui/core/MenuItem';
import Divider from '@material-ui/core/Divider';
import Typography from '@material-ui/core/Typography';
import tokensAPI from '../../helpers/api/tokensAPI';
import utils from '../../helpers/utils';
import greetings from '../../assests/greetings';

const useStyles = makeStyles((theme) => ({
  menuButton: {
    marginRight: theme.spacing(2),
    fontSize: '1rem',
    color: '#000',
  },
}));

const UserGreeting = () => {
  const userName = (localStorage.getItem('user') && JSON.parse(localStorage.getItem('user')).name) || 'User';
  const greeting = utils.randObjVal(greetings);

  return <Typography>{greeting} {userName}!</Typography>;
};

const UserMenu = (props) => {
  const { history } = props;
  const classes = useStyles();
  const [anchorEl, setAnchorEl] = useState(null);
  // eslint-disable-next-line no-unused-vars
  const [logOutErrors, setLogOutError] = useState(null);

  const handleSignOut = (event) => {
    event.preventDefault();
    tokensAPI.signOut(setLogOutError);
  };

  const handleMenuClick = (pageURL) => {
    history.push(pageURL);
    setAnchorEl(null);
  };
  return (
    <>
      <IconButton
        edge="start"
        className={classes.menuButton}
        color="inherit"
        aria-label="menu"
        onClick={(e) => setAnchorEl(e.currentTarget)}
      >
        <UserGreeting />
      </IconButton>
      <Menu
        id="user-menu"
        anchorEl={anchorEl}
        getContentAnchorEl={null}
        anchorOrigin={{
          vertical: 'bottom',
          horizontal: 'right',
        }}
        keepMounted
        transformOrigin={{
          vertical: 'top',
          horizontal: 'right',
        }}
        open={!!anchorEl}
        onClose={() => setAnchorEl(null)}
      >
        <MenuItem onClick={() => handleMenuClick('/profile')}>Profile</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/invoices')}>Invoices</MenuItem>
        <Divider />
        <MenuItem onClick={handleSignOut}>Sign Out</MenuItem>
      </Menu>
    </>
  );
};

export default withRouter(UserMenu);
