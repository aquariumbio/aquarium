import React from "react";
import Login from "../auth/Login";
import Logout from "../auth/Logout";
import Manager from "../Manager";
import Plan from "../Plan";
import Samples from "../Samples";
import Home from "../Home";
import User from "../User";
import Developer from "../Developer";
import Designer from "../Designer";
import Header from "../Header";
import { Redirect, Route, Switch } from "react-router-dom";
import { makeStyles } from "@material-ui/core/styles";
import { ThemeProvider, createMuiTheme } from '@material-ui/core/styles';

const useStyles = makeStyles({});
const theme = createMuiTheme({
  palette: {
    primary: {
      main: '#136390',
    },
  },
});
export default function App() {
  const classes = useStyles();
  return (
    <ThemeProvider theme={theme}>
      <div className={classes.container} data-test-name="app-container">
        { /* Users cannot interact with the app if they do not have a token */
          !localStorage.getItem('token') &&
          <Redirect to="/login"/>
             
        }

        { localStorage.getItem('token') && 
          <Header/>
        }

        <Switch>
          <Route exact path="/login" render={props => <Login {...props} />} /> 
          <Route exact path="/logout" render={props => <Logout {...props} />} /> 
          <Route exact path="/user" render={props => <User {...props} />} />
          <Route exact path="/manager" render={props => <Manager {...props} />} />
          <Route exact path="/Plan" render={props => <Plan {...props} />} />
          <Route exact path="/samples" render={props => <Samples {...props} />} />
          <Route exact path="/developer" render={props => <Developer {...props} />} />
          <Route exact path="/designer" render={props => <Designer {...props} />} />
          <Route from="/" render={props => <Home {...props} />} />
        </Switch>
      </div>
    </ThemeProvider>
  );
}
