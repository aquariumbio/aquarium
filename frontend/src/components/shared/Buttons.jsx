import React from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Button from '@material-ui/core/Button';
import { Link as RouterLink } from 'react-router-dom';

const useStyles = makeStyles((theme) => ({
  dark: {
    backgroundColor: '#065683',
    color: 'white',
    margin: theme.spacing(2),
    boxShadow: '0 2px 5px 0 rgba(0,0,0,.26)',
  },

  light: {
    backgroundColor: 'white',
    color: '#065683',
    margin: theme.spacing(2),
    boxShadow: '0 2px 5px 0 rgba(0,0,0,.26)',
  },

  dense: {
    margin: theme.spacing(0),
  },
}));

// Button with onClick hanlder
export const StandardButton = ({
  name, text, styling, dense, type, action,
}) => {
  const classes = useStyles();
  const cname = styling === 'light' ? classes.light : classes.dark;
  const noMargin = dense ? classes.dense : '';

  return (
    <Button
      name={name}
      className={`${cname} ${noMargin}`}
      component={RouterLink}
      type={type}
      onClick={() => action}
    >
      {text}
    </Button>
  );
};
StandardButton.propTypes = {
  name: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  styling: PropTypes.string,
  dense: PropTypes.bool,
  type: PropTypes.string,
  action: PropTypes.func.isRequired,
};
StandardButton.defaultProps = {
  styling: 'light',
  type: 'button',
  dense: false,
};

// Button with routing, takes a link string
export const LinkButton = ({
  name, text, styling, dense, type, linkTo,
}) => {
  const classes = useStyles();
  const cname = styling === 'light' ? classes.light : classes.dark;
  const noMargin = dense ? classes.dense : '';
  return (
    <Button
      name={name}
      className={`${cname} ${noMargin}`}
      component={RouterLink}
      type={type}
      to={linkTo}
    >
      {text}
    </Button>
  );
};
LinkButton.propTypes = {
  styling: PropTypes.string,
  dense: PropTypes.bool,
  name: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  type: PropTypes.string,
  linkTo: PropTypes.string.isRequired,
};
LinkButton.defaultProps = {
  styling: 'light',
  type: 'button',
  dense: false,
};
