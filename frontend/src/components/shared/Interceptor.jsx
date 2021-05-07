/* disabling forbidden prop spreading for react-router-dom */
/* eslint-disable react/jsx-props-no-spreading */
import React, { useState } from 'react';
import PropTypes from 'prop-types';
import tokensAPI from '../../helpers/api/tokensAPI';

import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles(() => ({
  modal_wrapper: {
    display: 'none',
    position: 'fixed',
    width: '100%',
    height: '100%',
    top: '72px',
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    zIndex: '1000',
  },

  modal_content: {
    width: '400px',
    margin: 'auto',
    padding: '20px',
    backgroundColor: 'white',
    borderLeft: '1px solid black',
    borderRight: '1px solid black',
    borderBottom: '1px solid black',
    textAlign: 'center',
  },

  input: {
    flexDirection: 'column',
    width: '50%',
  },

  button: {
    backgroundColor: '#065683',
    color: 'white',
    width: '50%',
    border: '2px solid #065683',

    '&:hover': {
      backgroundColor: 'white',
      color: '#065683',
    },
  },
}));

// eslint-disable-next-line no-unused-vars
const Interceptor = ({ setAlertProps }) => {
  const classes = useStyles();

  const [login, setLogin] = useState('');
  const [password, setPassword] = useState('');
  const [loginErrors, setLoginError] = useState('');
  const [logoutError, setLogOutError] = useState('');

  const handleSubmit = (event) => {
    event.preventDefault();
    tokensAPI.signIn(login, password, setLoginError);
  };

  const handleSignOut = (event) => {
    event.preventDefault();
    tokensAPI.signOut(setLogOutError);
  };

  const handleCloseError = () => {
    // eslint-disable-next-line no-undef
    closeError();
  };

  return (
    <>
      {/* modal login */}
      <div id='login_modal' className={classes.modal_wrapper}>
        <div className={classes.modal_content}>
          <form
            noValidate
            autoComplete="off"
            name="login"
            onSubmit={handleSubmit}
          >
            <Typography>
              <p><b>Your session timed out</b></p>
              <p>Please sign in again to continue<br /> or select [ Cancel ] to leave.</p>
            </Typography>
            <br />
            <TextField
              name="login"
              className={classes.input}
              required
              autoFocus
              id="login"
              label="Login"
              type="text"
              variant="outlined"
              value={login}
              onChange={(event) => setLogin(event.target.value)}
              data-test="username"
            />
            <br />
            <br />
            <TextField
              name="password"
              className={classes.input}
              required
              id="password"
              label="Password"
              type="password"
              variant="outlined"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              data-test="password"
            />
            <br />
            {loginErrors && <p>Invalid login/password combination</p>}
            <br />
            <Button className={classes.button} name="submit" type="submit">
              Sign In
            </Button>
          </form>
          <br />
          <Button className={classes.button} name="submit" onClick={handleSignOut}>
            Cancel
          </Button>
        </div>
      </div>
      {/* modal error message */}
      <div id='error_toast' className={classes.modal_wrapper}>
        <div className={classes.modal_content}>
          <Typography>
            <p><b>An unexpected error occurred</b></p>
            <p id="error_toast_message"></p>
            <p>Press [ OK ] to continue.</p>
          </Typography>

          <Button className={classes.button} name="OK" onClick={handleCloseError}>
            OK
          </Button>
        </div>
      </div>
    </>
  );
}

Interceptor.propTypes = {
  setAlertProps: PropTypes.func.isRequired,
};

export default Interceptor;
