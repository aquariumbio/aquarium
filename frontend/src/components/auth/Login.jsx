import React, { useState, useEffect } from 'react';
import Typography from '@material-ui/core/Typography'
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Grid from '@material-ui/core/Grid'
import { makeStyles } from '@material-ui/core/styles';
import { useHistory, Redirect } from "react-router-dom";
import axios from "axios";

const Login = (props) => {
  const classes = useStyles();
  let history = useHistory();

  const [ login, setLogin ] = useState("");
  const [ password, setPassword ] = useState("");
  const [ loginErrors, setLoginError ] = useState();
  const [ token, setToken ] = useState("");

  useEffect(() => {
    if (!loginErrors && token !== "") {
      // storetoken in local storage to keep user logged in between page refreshes
      localStorage.setItem('token', token);
    }
    const listener = event => {
      if (event.code === "Enter" || event.code === "NumpadEnter") {
        console.log("Enter key was pressed. Run your function.");
        // callMyFunction();
      }
    };
    document.addEventListener("keydown", listener);
    return () => {
      document.removeEventListener("keydown", listener);
    };
  });

  const handleSubmit = (event) => {
    event.preventDefault();
    axios
    .post(`user/sign_in?login=${login}&password=${password}`
    )
    .then(response => {
      if (response.data.status === 200 && response.data.data.token) {
        setLoginError()
        setToken(response.data.data.token)
        history.push("/");
        window.location.reload();
      }
  
      if (response.data.status !== 200) {
        return setLoginError(response.data.error)
      }
    });
  }

  if (localStorage.getItem("token")) {
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
              autoFocus={true}
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
