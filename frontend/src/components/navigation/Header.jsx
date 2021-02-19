// TODO: ADD PROP-TYPES
/* eslint-disable react/prop-types */
import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import { withRouter } from 'react-router-dom';
import IconButton from '@material-ui/core/IconButton';
import UserMenu from './UserMenu';
import LeftHamburgerMenu from './LeftHamburgerMenu';

const mainNavItems = [
  {
    menuTitle: 'PLAN',
    pageURL: '/plans',
  },
  {
    menuTitle: 'SAMPLES',
    pageURL: '/samples',
  },
  {
    menuTitle: 'MANAGER',
    pageURL: '/manager',
  },
  {
    menuTitle: 'DESIGNER',
    pageURL: '/designer',
  },
  {
    menuTitle: 'DEVELOPER',
    pageURL: '/developer',
  },

];

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
  menuButton: {
    marginRight: theme.spacing(3),
    color: '#fff',
    fontSize: '1rem',
  },
  title: {
    [theme.breakpoints.down('xs')]: {
      flexGrow: 1,
    },
  },
  headerOptions: {
    display: 'flex',
    flex: 1,
    color: '#fff',
    justifyContent: 'flex-end',

  },
  logo: {
    color: '#00ff22',
    fontSize: '22pt',
    fontWeight: 'bold',
    height: '20pt',
    lineHeight: '20pt',

  },
}));

const Header = (props) => {
  const { history } = props;
  const classes = useStyles();

  const handleButtonClick = (pageURL) => {
    history.push(pageURL);
  };

  return (
    <AppBar position="static" className={classes.root} component="nav">
      <Toolbar>
        <LeftHamburgerMenu />

        <IconButton
          edge="start"
          className={classes.logo}
          color="inherit"
          aria-label="home"
          onClick={() => handleButtonClick('/')}
        >
          AQUARIUM
        </IconButton>

        <div className={classes.headerOptions}>
          {mainNavItems.map((menuItem) => {
            const { menuTitle, pageURL } = menuItem;
            return (
              <IconButton
                key={menuTitle}
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
          <UserMenu />
        </div>
      </Toolbar>
    </AppBar>
  );
};

export default withRouter(Header);
