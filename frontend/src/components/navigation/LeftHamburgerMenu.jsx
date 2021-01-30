import React from 'react';
import PropTypes from 'prop-types';

import { withRouter } from 'react-router-dom';

import IconButton from '@material-ui/core/IconButton';
import MenuIcon from '@material-ui/icons/Menu';
import MenuItem from '@material-ui/core/MenuItem';
import Menu from '@material-ui/core/Menu';
import Divider from '@material-ui/core/Divider';
import createBrowserHistory from 'history/createBrowserHistory';

const LeftHamburgerMenu = () => {
  // allows force refresh when clicking on a hamburger menu item
  const history = createBrowserHistory({ forceRefresh: true });
  const [anchorEl, setAnchorEl] = React.useState(null);
  const open = Boolean(anchorEl);

  const handleMenu = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClick = (pageURL) => {
    history.push(pageURL);
    setAnchorEl(null);
  };

  return (
    <>
      <IconButton
        color="inherit"
        aria-label="menu"
        onClick={handleMenu}
      >
        <MenuIcon fontSize="large" />
      </IconButton>
      <Menu
        id="menu-appbar"
        anchorEl={anchorEl}
        getContentAnchorEl={null}
        anchorOrigin={{
          vertical: 'bottom',
          horizontal: 'center',
        }}
        keepMounted
        transformOrigin={{
          vertical: 'top',
          horizontal: 'center',
        }}
        open={open}
        onClose={() => setAnchorEl(null)}
      >
        <MenuItem onClick={() => handleMenuClick('/direct_purchase')}>Direct Purchase</MenuItem>
        <Divider />
        <MenuItem onClick={() => handleMenuClick('/logs')}>Logs</MenuItem>
        <Divider />
        <MenuItem onClick={() => handleMenuClick('/users')}>Users</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/groups')}>Groups</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/announcements')}>Announcements</MenuItem>
        <Divider />
        <MenuItem onClick={() => handleMenuClick('/budgets')}>Budgets</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/invoices')}>Invoices</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/parameters')}>Parameters</MenuItem>
        <Divider />
        <MenuItem onClick={() => handleMenuClick('/sample_types')}>Sample Type Definitions</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/object_types')}>Object Types</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/wizards')}>Location Wizards</MenuItem>
        <Divider />
        <MenuItem onClick={() => handleMenuClick('/import')}>Import Workflows</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/publish')}>Export Workflows</MenuItem>
        <Divider />
        <MenuItem component="a" href="http://klavinslab.org/aquarium">Help</MenuItem>
      </Menu>
    </>
  );
};

export default withRouter(LeftHamburgerMenu);
