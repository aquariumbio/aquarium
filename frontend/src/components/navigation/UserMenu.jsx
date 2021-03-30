// TODO: ADD PROP-TYPES
/* eslint-disable react/prop-types */
import React, { useState } from 'react';
import { withRouter } from 'react-router-dom';
import { makeStyles } from '@material-ui/core/styles';
import IconButton from '@material-ui/core/IconButton';
import Menu from '@material-ui/core/Menu';
import MenuItem from '@material-ui/core/MenuItem';
import Divider from '@material-ui/core/Divider';
import tokensAPI from '../../helpers/api/tokensAPI';
import UserGreeting from './UserGreeting';

const useStyles = makeStyles((theme) => ({
  menuButton: {
    marginRight: theme.spacing(2),
    fontSize: '16px',
    color: '#000',
  },
}));

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
        id="user-menu-button"
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
