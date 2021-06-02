import React, { Fragment } from 'react';
import {
  string, element, arrayOf, oneOfType, bool, objectOf,
} from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import List from '@material-ui/core/List';

const useStyles = makeStyles((theme) => ({
  titleDiv: {
    height: '24px',
    borderBottom: '1px #DDD solid',
    marginBottom: theme.spacing(1),
    fontWeight: 'light',
    paddingLeft: theme.spacing(1),

  },
  list: {
    backgroundColor: theme.palette.background.paper,
    color: 'rgba(0, 0, 0, 0.87)',

    '& .Mui-selected': {
      background: theme.palette.action.selected,
    },
    '& .MuiListItemIcon-root': {
      maxWidth: '45px',
    },
    flexGrow: 1,
  },
  spacingTop: {
    marginTop: '30px',
  },
  scrollDiv: {
    overflowY: 'scroll',
    paddingRight: theme.spacing(0.5), // account for scroll bar on small screen
    paddingBottom: theme.spacing(2),
  },
}));

const ListScroll = (props) => {
  const {
    title,
    height,
    spacingTop, // Add top margin when using multiple lists
    children,
    ariaLabel,
  } = props;

  const classes = useStyles();

  return (
    <>
      <div className={`${classes.titleDiv} ${spacingTop ? classes.spacingTop : ''}`}>
        <Typography noWrap variant="caption">
          {title}
        </Typography>
      </div>
      <div
        className={classes.scrollDiv}
        style={{ height }}
      >
        <List
          role="tablist"
          aria-label={ariaLabel || title}
          className={classes.list}
          disablePadding
          data-cy={ariaLabel || title}
        >
          {children}
        </List>
      </div>
    </>
  );
};

ListScroll.propTypes = {
  title: string,
  children: oneOfType([
    element,
    arrayOf(element),
    arrayOf(arrayOf(element), element),
    objectOf(element),
  ]),
  height: string,
  spacingTop: bool,
  // eslint-disable-next-line react/require-default-props
  ariaLabel: string,
};

ListScroll.defaultProps = {
  title: '',
  children: React.createElement('div'),
  height: 'calc(100vh - 350px)',
  spacingTop: false,
};

export default ListScroll;
