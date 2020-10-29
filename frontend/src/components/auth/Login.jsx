import React, { useState, useEffect } from 'react';
import Typography from '@material-ui/core/Typography'
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid'
import { makeStyles } from '@material-ui/core/styles';
import { Redirect } from "react-router-dom";
import API from '../../helpers/api';

const Login = (props) => {
  const classes = useStyles();
  const [ login, setLogin ] = useState("");
  const [ password, setPassword ] = useState("");
  const [ loginErrors, setLoginError ] = useState();

  useEffect(() => {
    // USER LISTENER TO ALLOW ENTER TO SUBMIT FORM
    const listener = event => {
      if (event.code === "Enter" || event.code === "NumpadEnter") {
      }
    };
    document.addEventListener("keydown", listener);
    return () => {
      document.removeEventListener("keydown", listener);
    };
  });

  const handleSubmit = (event) => {
    event.preventDefault();
      API.sign_in(login, password, setLoginError);
  }

  if (sessionStorage.getItem("token")) {
    return <Redirect to="/" />;
  }
  return (
    <div className={classes.root}>
      <header>
        <Typography variant="h1" gutterBottom align="center">
          Your Lab
        </Typography>
        <Typography variant="subtitle1" gutterBottom align="center">
          Powered by Aquarium
        </Typography>
      </header>

      <form className={classes.form} noValidate autoComplete="off" name="login" onSubmit={handleSubmit}>
          <Grid item xs={12} sm={12}>
            <TextField 
              name="login" 
              className={classes.input}
              required 
              id="login" 
              label="Login" 
              variant="outlined" 
              value={login} 
              onChange={ event => setLogin(event.target.value)}
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
              onChange={ event => setPassword(event.target.value)}
              data-test="password"/>
        </Grid>
        { loginErrors &&
          <p>Invalid login/password combination</p>
        }
        <Button className={classes.button} name="submit" type="submit" >SIGN IN</Button>
      </form>
    </div>
  )
}
export default Login;

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
    marginTop: '20%',
  },
  form: {
    margin: theme.spacing(3),
    textAlign: 'center',

    '& > p': {
      color: 'red',
      marginLeft: 'auto',
      marginRight: 'auto',
      width: 'auto',
    },
  },
  input: {
    margin: theme.spacing(2),
  },

  button: {
    display: 'block',
    marginLeft: 'auto',
    marginRight: 'auto',
    backgroundColor: '#065683',
    color: 'white',

    '& :hover': {
      backgroundColor: 'white',
      color: '#065683',
      border: '.25em solid #065683'
    }
  },

}));
