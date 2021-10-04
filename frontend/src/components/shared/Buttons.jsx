import React from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Button from '@material-ui/core/Button';
import { Link as RouterLink } from 'react-router-dom';
import AttachFileIcon from '@material-ui/icons/AttachFile';
import Tooltip from '@material-ui/core/Tooltip';

const useStyles = makeStyles((theme) => ({
  dark: {
    backgroundColor: theme.palette.primary.main,
    color: 'rgb(255,255,255)',
    margin: `${theme.spacing(2)}px ${theme.spacing(2)}px ${theme.spacing(2)}px 0px `,
    boxShadow: '0 2px 5px 0 rgba(0,0,0,.26)',
    '&:disabled': {
      backgroundColor: 'rgb(255,255,255)',
      color: 'rgba(0, 0, 0, 0.26)',
    },
  },

  light: {
    backgroundColor: 'rgb(255, 255, 255)',
    color: theme.palette.primary.main,
    margin: `${theme.spacing(2)}px ${theme.spacing(2)}px ${theme.spacing(2)}px 0px `,
  },

  dense: {
    margin: theme.spacing(0),
  },
}));

// Button with onClick hanlder
export const StandardButton = ({
  name,
  text,
  handleClick,
  dark = false,
  dense = false,
  type = 'button',
  testName = { name },
  disabled = false,
  icon = false,
  variant,
}) => {
  const classes = useStyles();
  const cname = dark ? classes.dark : classes.light;
  const noMargin = dense ? classes.dense : '';
  const validIcons = {
    attach: <AttachFileIcon />,
  };

  return (
    <Tooltip title={name}>
      <Button
        name={name}
        className={`${cname} ${noMargin}`}
        type={type}
        onClick={handleClick}
        data-cy={testName}
        disabled={disabled}
        color="primary"
        startIcon={validIcons[icon]}
        variant={variant}
      >
        {text}
      </Button>
    </Tooltip>
  );
};
StandardButton.propTypes = {
  name: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  dark: PropTypes.bool,
  dense: PropTypes.bool,
  type: PropTypes.string,
  handleClick: PropTypes.func.isRequired,
  testName: PropTypes.string,
  disabled: PropTypes.bool,
  icon: PropTypes.bool,
  variant: PropTypes.oneOf(['contained', 'outlined', 'text']),

};
StandardButton.defaultProps = {
  dark: false,
  type: 'button',
  dense: false,
  disabled: false,
  testName: 'StandardButton',
  icon: false,
  variant: 'outlined',
};

// Button with routing, takes a link string
export const LinkButton = ({
  name,
  linkTo,
  text,
  dark = false,
  dense = false,
  testName = { name },
  disabled = false,
}) => {
  const classes = useStyles();
  const cname = dark ? classes.dark : classes.light;
  const noMargin = dense ? classes.dense : '';
  return (
    <Tooltip title={name}>
      <Button
        name={name}
        className={`${cname} ${noMargin}`}
        component={RouterLink}
        to={linkTo}
        data-cy={testName}
        disabled={disabled} // aria-disabled
      >
        {text}
      </Button>
    </Tooltip>
  );
};
LinkButton.propTypes = {
  dark: PropTypes.bool,
  dense: PropTypes.bool,
  name: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  linkTo: PropTypes.string.isRequired,
  testName: PropTypes.string,
  disabled: PropTypes.bool,
};
LinkButton.defaultProps = {
  dark: false,
  dense: false,
  disabled: false,
  testName: 'LinkButton',
};

export const HomeButton = () => (
  <Button
    name="home"
    aria-label="home"
    component={RouterLink}
    to="/"
  >
    <img src={`${process.env.PUBLIC_URL}AQ-Brandmark.png`} alt="logo" width="40" height="40" />
  </Button>
);
