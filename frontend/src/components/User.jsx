import React, { useEffect, useState } from 'react';
import { makeStyles } from "@material-ui/core/styles";
import IconButton from "@material-ui/core/IconButton";
import MenuItem from "@material-ui/core/MenuItem";
import Menu from "@material-ui/core/Menu";
import { withRouter, Redirect} from "react-router-dom";
import axios from "axios";

const useStyles = makeStyles(theme => ({
  menuButton: {
    marginRight: theme.spacing(2)
  },
}));

const User = (props) => {
  const { history} = props;
  const classes = useStyles();
  const [anchorEl, setAnchorEl] = useState(null);
  const open = Boolean(anchorEl);

  const [ logOutErrors, setLoginOutError ] = useState(null);
  const [ logout, setlogout ] = useState(false);

  useEffect(() => {
    if (logout && !logOutErrors !== "") {
      // storetoken in local storage to keep user logged in between page refreshes
      localStorage.clear('token');
    }
  });

  const handleSignOut = (event) => {
    event.preventDefault();
    const token = localStorage.getItem('token');

    axios
    .post(`user/sign_out?token=${token}`)
    .then(response => {
      if (response.data.status === 200) {
        setlogout(true);
        history.push("/login");
        window.location.reload();
      }

      if (response.data.status !== 200) {
        return setLoginOutError(response.data.error)
      }
    })
  }

  const handleMenu = event => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClick = pageURL => {
    history.push(pageURL);
    setAnchorEl(null);
  };
  if (!localStorage.getItem("token")) {
    return <Redirect to="/login" />;
  }
  return ( 
    <>
      <IconButton
        edge="start"
        className={classes.menuButton}
        color="inherit"
        aria-label="menu"
        onClick={handleMenu}
      >
        USER
      </IconButton>
      <Menu
        id="user-menu"
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
        <MenuItem onClick={() => handleMenuClick("/users")}>
          Profile
        </MenuItem>
        <MenuItem onClick={() => handleMenuClick("/invoices")}>
          Invoices
        </MenuItem>
        <MenuItem onClick={handleSignOut}>
          Sign Out
        </MenuItem>
      </Menu>
    </>
   );
}
 
export default withRouter(User);

