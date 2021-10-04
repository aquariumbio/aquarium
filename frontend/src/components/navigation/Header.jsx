// TODO: ADD PROP-TYPES
/* eslint-disable react/prop-types */
import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import { withRouter, Link as RouterLink } from 'react-router-dom';
import Tabs from '@material-ui/core/Tabs';
import Tab from '@material-ui/core/Tab';
import Tooltip from '@material-ui/core/Tooltip';
import UserMenu from './UserMenu';
import LeftHamburgerMenu from './LeftHamburgerMenu';
import { HomeButton } from '../shared/Buttons';

const pages = [
  {
    title: 'Design',
    url: '/design',
  },
  {
    title: 'Develop',
    url: '/develop',
  },
  {
    title: 'Manage',
    url: '/jobs',
  },
  {
    title: 'Samples',
    url: '/samples',
  },
  {
    title: 'Plans',
    url: '/plans',
  },
];

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
    height: '74px',
    borderBottom: '1px solid #ddd',
    '& .MuiToolbar-regular': {
      display: 'flex',
      justifyContent: 'space-between',
    },
    '& .MuiTabs-root': {
      display: 'inline-flex',
      '& .MuiTab-textColorPrimary': {
        color: '#000',
        '& .Mui-selected': {
          color: '#000',
        },
      },
      '& .MuiTabs-indicator': {
        backgroundColor: '#2399cc',
      },
    },
  },
  headerOptions: {
    display: 'inline-flex',
  },
  tablist: {
    maxWidth: '450px',
  },
  tab: {
    textTransform: 'none',
    fontSize: '1rem',
    [theme.breakpoints.up('sm')]: {
      maxWidth: '100px',
      minWidth: '80px',
    },
  },
}));

const Header = ({ location }) => {
  const classes = useStyles();
  const [value, setValue] = useState(false);

  const handleChange = (event, newValue) => {
    setValue(newValue);
  };

  useEffect(() => {
    const page = location.pathname.split('/')[1];
    const tabSelected = pages.findIndex((item) => item.title.toUpperCase() === page.toUpperCase());

    if (tabSelected === -1) {
      // Remove selected indicator when route does not match tabbed pages
      setValue(false);
    } else if (value !== tabSelected) {
      // Set tab on inital load
      setValue(tabSelected);
    }
  });

  return (
    <AppBar position="fixed" elevation={0} className={classes.root} component="header">
      <Toolbar>
        <div className={classes.headerOptions}>
          <Tooltip title="Menu">
            {/* Wrap custom components in fragment to avoid
                'Invalid prop `children` supplied to `ForwardRef(Tooltip)`' error */}
            <>
              <LeftHamburgerMenu />
            </>
          </Tooltip>

          <Tooltip title="Home">
            <>
              <HomeButton />
            </>
          </Tooltip>

          <Tabs
            value={value}
            onChange={handleChange}
            indicatorColor="primary"
            textColor="primary"
            className={classes.tablist}
          >
            {pages.map((menuItem) => {
              const { title, url } = menuItem;
              return (
                <Tab
                  key={title}
                  label={title}
                  to={url}
                  component={RouterLink}
                  className={classes.tab}
                />
              );
            })}
          </Tabs>

        </div>
        <Tooltip title="User Menu">
          <>
            <UserMenu />
          </>
        </Tooltip>

      </Toolbar>
    </AppBar>
  );
};

export default withRouter(Header);
