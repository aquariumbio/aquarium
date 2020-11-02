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
    marginRight: theme.spacing(3),
    color: '#fff',
    [theme.breakpoints.between('sm', 'md')]: {
      fontSize: 'small',
    },

  },
  title: {
    [theme.breakpoints.down("xs")]: {
      flexGrow: 1
    }
  },
  headerOptions: {
    display: "flex",
    flex: 1,
    color: '#fff',
    justifyContent: 'flex-end'

  },
  logo: {
    color: "#00ff22",
    fontSize: "22pt",
    fontWeight: "bold",
    height: "20pt",
    lineHeight: "20pt",

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
          <DropdownMenu menuItems={leftNavMenuItems}/>
          
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
            <div className={classes.headerOptions}>
            
            <DropdownMenu className={classes.menuButton} menuItems={mainNavItems}/>
            <User/>
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
  },
];