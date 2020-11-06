/* disabling forbidden prop spreading for react-router-dom */
/* eslint-disable react/jsx-props-no-spreading */
import React from 'react';
import { Redirect, Route, Switch } from 'react-router-dom';
import { makeStyles, ThemeProvider, createMuiTheme } from '@material-ui/core/styles';

import Header from '../Header';
import LoginDialog from '../LoginDialog';
import UserMenu from '../UserMenu';
import ManagerPage from '../ManagerPage';
import PlansPage from '../PlansPage';
import SamplesPage from '../SamplesPage';
import HomePage from '../HomePage';
import DeveloperPage from '../DeveloperPage';
import DesignerPage from '../DesignerPage';
import ParametersPage from '../ParametersPage';
import RolesPage from '../RolesPage';
import UsersPage from '../UsersPage';
import SampleTypesPage from '../SampleTypesPage';
import AnnouncementsPage from '../AnnouncementsPage';
import BudgetsPage from '../BudgetsPage';
import ContainersPage from '../ContainersPage';
import DirectPurchasePage from '../DirectPurchasePage';
import ExportWorkflowsPage from '../ExportWorkflowsPage';
import InvoicesPage from '../InvoicesPage';
import LocationWizardsPage from '../LocationWizardsPage';
import LogsPage from '../LogsPage';
import API from '../../helpers/API';

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
          (!sessionStorage.getItem('token') || !API.isAuthenticated)
          && <Redirect to="/login" />
        }
        <Switch>
          <Route path="/login" render={(props) => <LoginDialog {...props} />} />
          <>
            {/* Header should show on all pages except login */}
            <Header />
            <Route exact path="/user" render={(props) => <UserMenu {...props} />} />
            <Route exact path="/manager" render={(props) => <ManagerPage {...props} />} />
            <Route exact path="/plans" render={(props) => <PlansPage {...props} />} />
            <Route exact path="/samples" render={(props) => <SamplesPage {...props} />} />
            <Route exact path="/developer" render={(props) => <DeveloperPage {...props} />} />
            <Route exact path="/designer" render={(props) => <DesignerPage {...props} />} />
            <Route exact path="/users" render={(props) => <UsersPage {...props} />} />
            <Route exact path="/sample_type_definitions" render={(props) => <SampleTypesPage {...props} />} />
            <Route exact path="/announcements" render={(props) => <AnnouncementsPage {...props} />} />
            <Route exact path="/budgets" render={(props) => <BudgetsPage {...props} />} />
            <Route exact path="/object_types" render={(props) => <ContainersPage {...props} />} />
            <Route exact path="/direct_purchase" render={(props) => <DirectPurchasePage {...props} />} />
            <Route exact path="/publish" render={(props) => <ExportWorkflowsPage {...props} />} />
            <Route exact path="/invoices" render={(props) => <InvoicesPage {...props} />} />
            <Route exact path="/wizards" render={(props) => <LocationWizardsPage {...props} />} />
            <Route exact path="/logs" render={(props) => <LogsPage {...props} />} />
            <Route exact path="/parameters" render={(props) => <ParametersPage {...props} />} />
            <Route exact path="/roles" render={(props) => <RolesPage {...props} />} />

            <Route exact path="/" render={(props) => <HomePage {...props} />} />
          </>
        </Switch>
      </div>
    </ThemeProvider>
  );
}
