import React from 'react';
import PropTypes from 'prop-types';
import IconButton from '@material-ui/core/IconButton';
import MenuIcon from '@material-ui/icons/Menu';
import MenuItem from '@material-ui/core/MenuItem';
import Menu from '@material-ui/core/Menu';
import { Divider } from '@material-ui/core';
import { withRouter } from 'react-router-dom';

const LeftHamburgerMenu = (props) => {
  const { history } = props;
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
        <MenuItem onClick={() => handleMenuClick('/containers')}>Containers</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/wizards')}>Location Wizards</MenuItem>
        <Divider />
        <MenuItem onClick={() => handleMenuClick('/import_workflows)')}>Import Workflows</MenuItem>
        <MenuItem onClick={() => handleMenuClick('/export_workflows')}>Export Workflows</MenuItem>
        <Divider />
        <MenuItem component="a" href="http://klavinslab.org/aquarium">Help</MenuItem>
      </Menu>
    </>
  );
};

export default withRouter(LeftHamburgerMenu);

LeftHamburgerMenu.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  history: PropTypes.object.isRequired,
};
