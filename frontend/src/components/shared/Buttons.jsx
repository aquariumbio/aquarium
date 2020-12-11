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
  name, text, dark, dense, type, handleClick, testName,
}) => {
  const classes = useStyles();
  const cname = dark ? classes.dark : classes.light;
  const noMargin = dense ? classes.dense : '';

  return (
    <Button
      name={name}
      className={`${cname} ${noMargin}`}
      type={type}
      onClick={handleClick}
      cy-data={testName}
    >
      {text}
    </Button>
  );
};
StandardButton.propTypes = {
  name: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  dark: PropTypes.bool,
  dense: PropTypes.bool,
  type: PropTypes.string,
  handleClick: PropTypes.func.isRequired,
  testName: PropTypes.string.isRequired,

};
StandardButton.defaultProps = {
  dark: false,
  type: 'button',
  dense: false,
};

// Button with routing, takes a link string
export const LinkButton = ({
  name, text, dark, dense, type, linkTo, testName,
}) => {
  const classes = useStyles();
  const cname = dark ? classes.dark : classes.light;
  const noMargin = dense ? classes.dense : '';
  return (
    <Button
      name={name}
      className={`${cname} ${noMargin}`}
      component={RouterLink}
      type={type}
      to={linkTo}
      cy-data={testName}
    >
      {text}
    </Button>
  );
};
LinkButton.propTypes = {
  dark: PropTypes.bool,
  dense: PropTypes.bool,
  name: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  type: PropTypes.string,
  linkTo: PropTypes.string.isRequired,
  testName: PropTypes.string.isRequired,
};
LinkButton.defaultProps = {
  dark: false,
  type: 'button',
  dense: false,
};
