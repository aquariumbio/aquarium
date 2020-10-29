import React from "react";
import { makeStyles, useTheme } from "@material-ui/core/styles";
import AppBar from "@material-ui/core/AppBar";
import Toolbar from "@material-ui/core/Toolbar";
import useMediaQuery from "@material-ui/core/useMediaQuery";
import { withRouter } from "react-router-dom";
import DropdownMenu from "./shared/DropdownMenu";
import User from "./User";
import IconButton from "@material-ui/core/IconButton";

const useStyles = makeStyles(theme => ({
  root: {
    flexGrow: 1,

  },
  menuButton: {
    margin: theme.spacing(0,2),
    color: '#fff',
    fontSize: '.9rem',
  },
  headerOptions: {
    display: "flex",
    flex: 1,
    color: '#fff',
    justifyContent: 'flex-end'
  },
  logo: {
    color: "#00ff22",
    fontSize: "1.5rem",
    fontWeight: "bold",
  },
}));

const Header = props => {
  const { history } = props;
  const classes = useStyles();
  const theme = useTheme();
  const isMediumScreen = useMediaQuery(theme.breakpoints.down("sm"));

  const handleButtonClick = pageURL => {
    history.push(pageURL);
  };
  
  return (
    <div >
      <AppBar position="static" className={classes.root}>
        <Toolbar>
          {/* LEFT HAMBURGER MENU*/}
          <DropdownMenu className={classes.menuButton} menuItems={leftNavMenuItems}/>
          
          <IconButton
            edge="start"
            className={classes.logo}
            color="inherit"
            aria-label="home"
            onClick={() => handleButtonClick("/")}
          >
          AQUARIUM
          </IconButton>

          {isMediumScreen ? (
            <div className={classes.menu}>
            
            <DropdownMenu className={classes.menuButton} menuItems={mainNavItems} title="MENU"/>
            <User />
            </div>
          ) : (
            <div className={classes.headerOptions}>
              {mainNavItems.map((menuItem, index) => {
                  const { menuTitle, pageURL } = menuItem;
                  return (
                    <IconButton
                      key={index}
                      edge="start"
                      className={classes.menuButton}
                      color="inherit"
                      aria-label={menuItem}
                      onClick={() => handleButtonClick(pageURL)}
                    >
                      {menuTitle}
                    </IconButton>

                  );
                })}
              <User/>
            </div>
          )}
        </Toolbar>
      </AppBar>
    </div>
  );
};

export default withRouter(Header);

const mainNavItems = [
  {
    menuTitle: "PLAN",
    pageURL: "/plan"
  },
  {
    menuTitle: "SAMPLES",
    pageURL: "/samples"
  },
  {
    menuTitle: "MANAGER",
    pageURL: "/manager"
  },
  {
    menuTitle: "DESIGNER",
    pageURL: "/designer"
  },
  {
    menuTitle: "DEVELOPER",
    pageURL: "/developer"
  },

];

const leftNavMenuItems = [
  {
    menuTitle: "Direct Purchase",
    pageURL: "/direct_purchase"
  },
  {
    menuTitle: "Logs",
    pageURL: "/logs"
  },
  {
    menuTitle: "Users",
    pageURL: "/users"
  },
  {
    menuTitle: "Groups",
    pageURL: "/groups"
  },
  {
    menuTitle: "Roles",
    pageURL: "/roles"
  },
  {
    menuTitle: "Announcements",
    pageURL: "/announcements"
  },
  {
    menuTitle: "Budgets",
    pageURL: "/budgets"
  },
  {
    menuTitle: "Invoices",
    pageURL: "/invoices"
  },
  {
    menuTitle: "Parameters",
    pageURL: "/parameters"
  },
  {
    menuTitle: "Sampel Type Definitions",
    pageURL: "/sample_type_definitions"
  },
  {
    menuTitle: "Containers",
    pageURL: "/containers"
  },
  {
    menuTitle: "Location Wizards",
    pageURL: "/location_wizards"
  },
  {
    menuTitle: "Import Workflows",
    pageURL: "/workflows/imports"
  },
  {
    menuTitle: "Export Workflows",
    pageURL: "/workflows/exports"
  },
  {
    menuTitle: "Help",
    pageURL: "/help"
    // link to https://www.aquarium.bio/
  },
];