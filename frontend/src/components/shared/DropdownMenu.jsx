import React from 'react';
import IconButton from "@material-ui/core/IconButton";
import MenuIcon from "@material-ui/icons/Menu";
import MenuItem from "@material-ui/core/MenuItem";
import Menu from "@material-ui/core/Menu";

const DropdownMenu = (props) => {
  const { history, menuItems} = props;
  const [anchorEl, setAnchorEl] = React.useState(null);
  const open = Boolean(anchorEl);

  const handleMenu = event => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClick = pageURL => {
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
          vertical: "bottom",
          horizontal: "center"
        }}
        keepMounted
        transformOrigin={{
          vertical: "top",
          horizontal: "center"
        }}
        open={open}
        onClose={() => setAnchorEl(null)}
      >
        {
          menuItems.map((menuItem, index) => {
            const { menuTitle, pageURL } = menuItem;

            return (
              <MenuItem key={index} onClick={() => handleMenuClick(pageURL)}>
                {menuTitle}
              </MenuItem>
            );
          })
        }
      </Menu>
    </>
   );
}
 
export default DropdownMenu;