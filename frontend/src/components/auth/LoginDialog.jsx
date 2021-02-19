import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import { makeStyles } from '@material-ui/core/styles';
import Divider from '@material-ui/core/Divider';
import { useHistory, withRouter } from 'react-router-dom';
import tokensAPI from '../../helpers/api/tokens';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
    marginTop: '10%',
  },
  divider: {
    marginTop: '40px',
    marginBottom: '40px',
  },
  labName: {
    fontSize: '112px',
    fontWeight: '400',
    letterSpacing: '-.01em',
    lineHeight: '112px',
  },
  form: {
    margin: theme.spacing(3),
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    width: '50%',
    marginLeft: 'auto',
    marginRight: 'auto',

    '& > p': {
      color: 'red',
      marginLeft: 'auto',
      marginRight: 'auto',
      width: 'auto',
    },
  },

  input: {
    margin: theme.spacing(3, 2),
    flexDirection: 'column',
    width: '50%',
  },

  button: {
    backgroundColor: '#065683',
    color: 'white',
    width: '50%',
    margin: theme.spacing(3, 2),

    '& :hover': {
      backgroundColor: 'white',
      color: '#065683',
      border: '.25em solid #065683',
    },
  },

  subtitle: {
    color: '#66b',
    fontSize: '20px',
  },
}));

const LoginDialog = ({ setIsLoading }) => {
  const classes = useStyles();
  const history = useHistory();

  const [login, setLogin] = useState('');
  const [password, setPassword] = useState('');
  const [loginErrors, setLoginError] = useState();

  const handleSubmit = (event) => {
    event.preventDefault();
    tokensAPI.signIn(login, password, setLoginError);
  };

  setIsLoading(false); // Prevent loading spinnter on login screen

  useEffect(() => {
    const listener = (event) => {
      if (event.code === 'Enter' || event.code === 'NumpadEnter') {
        handleSubmit(event);
      }
    };
    document.addEventListener('keydown', listener);
    return () => {
      document.removeEventListener('keydown', listener);
    };
  });

  if (localStorage.getItem('token') && tokensAPI.isAuthenticated()) {
    history.push('/');
  }
  return (
    <div className={classes.root}>
      <header>
        <Typography className={classes.labName} variant="h1" gutterBottom align="center">
          Your Lab
        </Typography>
        <Typography className={classes.subtitle} variant="subtitle1" gutterBottom align="center">
          Powered by Aquarium
        </Typography>
      </header>

      <Divider className={classes.divider} />

      <form className={classes.form} noValidate autoComplete="off" name="login" onSubmit={handleSubmit}>
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

        {loginErrors &&
          <p>Invalid login/password combination</p>}

        <Button className={classes.button} name="submit" type="submit">SIGN IN</Button>
      </form>
    </div>
  );
};

LoginDialog.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
};

export default withRouter(LoginDialog);
