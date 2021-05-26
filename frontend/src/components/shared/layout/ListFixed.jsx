import React, { Fragment } from 'react';
import {
  string, element, arrayOf, oneOfType,
} from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import List from '@material-ui/core/List';

const useStyles = makeStyles((theme) => ({
  div: {
    height: '24px',
    borderBottom: '1px #DDD solid',
    marginBottom: theme.spacing(1),
  },
  list: {
    backgroundColor: theme.palette.background.paper,
    color: 'rgba(0, 0, 0, 0.87)',

    '& .Mui-selected': {
      background: 'rgba(64, 222, 253, 0.13)',
    },
    '& .MuiListItemIcon-root': {
      maxWidth: '45px',
    },
    flexGrow: 1,
    overflow: 'overlay',
  },
}));

const ListFixed = (props) => {
  const { title, children, ariaLabel } = props;
  const classes = useStyles();

  return (
    <>
      <div className={classes.div}>
        <Typography noWrap variant="subtitle2">
          {title}
        </Typography>
      </div>
      <List
        role="tablist"
        aria-label={ariaLabel || title}
        className={classes.list}
        disablePadding
        data-cy={ariaLabel || title}
      >
        {children}
      </List>
    </>
  );
};

ListFixed.propTypes = {
  title: string,
  children: oneOfType([arrayOf(element), element]),
  // eslint-disable-next-line react/require-default-props
  ariaLabel: string,
};

ListFixed.defaultProps = {
  title: '',
  children: React.createElement('div'),
};

export default ListFixed;
