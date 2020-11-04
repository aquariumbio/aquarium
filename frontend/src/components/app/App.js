import React, { Fragment } from "react";
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
import { ThemeProvider, createMuiTheme } from "@material-ui/core/styles";
import API from "../../helpers/API";

const useStyles = makeStyles({});
const theme = createMuiTheme({
  palette: {
    primary: {
      main: "#136390",
    },
  },
});

export default function App() {
  const classes = useStyles();

  return (
    <ThemeProvider theme={theme}>
      <div className={classes.container} data-test-name="app-container">
        { /* Users cannot interact with the app if they do not have a token */
          (!sessionStorage.getItem("token") || !API.isAuthenticated ) &&
          <Redirect to="/login"/>
        }
        <Switch>
          <Route path="/login" render={props => <Login {...props} />} /> 
          <Fragment> {/* Header should show on all pages except login */}
            <Header/>
            <Route exact path="/logout" render={props => <Logout {...props} />} /> 
            <Route exact path="/user" render={props => <User {...props} />} />
            <Route exact path="/manager" render={props => <Manager {...props} />} />
            <Route exact path="/Plan" render={props => <Plan {...props} />} />
            <Route exact path="/samples" render={props => <Samples {...props} />} />
            <Route exact path="/developer" render={props => <Developer {...props} />} />
            <Route exact path="/designer" render={props => <Designer {...props} />} />
            <Route exact path="/" render={props => <Home {...props} />} />
          </Fragment>
        </Switch>
      </div>
    </ThemeProvider>
  );
}
