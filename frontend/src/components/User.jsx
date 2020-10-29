import React, { useState } from 'react';
import { makeStyles } from "@material-ui/core/styles";
import IconButton from "@material-ui/core/IconButton";
import MenuItem from "@material-ui/core/MenuItem";
import Menu from "@material-ui/core/Menu";
import { withRouter, Redirect} from "react-router-dom";
import API from '../helpers/api'
import Divider from '@material-ui/core/Divider';

const useStyles = makeStyles(theme => ({
  menuButton: {
    margin: theme.spacing(0,2),
    color: '#00ff22',
    fontSize: '.9rem',
  },
  menu: {
    borderTopLeftRadius: '0px',
    borderTopRightRadius: '0px',
  }
}));

const User = (props) => {
  const { history} = props;
  const classes = useStyles();
  const [anchorEl, setAnchorEl] = useState(null);
  const open = Boolean(anchorEl);

  const [ logOutErrors, setLogOutError ] = useState(null);

  const handleSignOut = (event) => {
    event.preventDefault();
    API.sign_out(setLogOutError) 
    history.push("/login");
  }

  const handleMenu = event => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClick = pageURL => {
    history.push(pageURL);
    setAnchorEl(null);
  };
  if (!sessionStorage.getItem("token")) {
    return <Redirect to="/login" />;
  }
  return ( 
    <>
      <IconButton
        edge="start"
        className={classes.menuButton}
        color="inherit"
        aria-label="user menu"
        onClick={handleMenu}
      >
        ● USER
      </IconButton>
      <Menu
        id="user-menu"
        style={{
          borderTopLeftRadius: '0px',
          borderTopRightRadius: '0px',
        }}
        anchorEl={anchorEl}
        getContentAnchorEl={null} 
        anchorOrigin={{
          vertical: "bottom",
          horizontal: "right"
        }}
        keepMounted
        transformOrigin={{
          vertical: "top",
          horizontal: "right"
        }}
        open={open}
        onClose={() => setAnchorEl(null)}
      >
        <MenuItem onClick={() => handleMenuClick("/users/:id")}>
          Profile
        </MenuItem>
        <MenuItem onClick={() => handleMenuClick("/invoices")}>
          Invoices
        </MenuItem>
        <Divider light />
        <MenuItem onClick={handleSignOut}>
          Sign Out
        </MenuItem>
      </Menu>
    </>
   );
}
 
export default withRouter(User);

