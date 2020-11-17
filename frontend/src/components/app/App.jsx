/* disabling forbidden prop spreading for react-router-dom */
/* eslint-disable react/jsx-props-no-spreading */
import { createMuiTheme, makeStyles, ThemeProvider } from '@material-ui/core/styles';
import React from 'react';
import { Redirect, Route, Switch } from 'react-router-dom';
import API from '../../helpers/API';
import AnnouncementsPage from '../announcements/AnnouncementsPage';
import LoginDialog from '../auth/LoginDialog';
import BudgetsPage from '../budgets/BudgetsPage';
import ContainersPage from '../containers/ContainersPage';
import DesignerPage from '../designer/DesignerPage';
import DeveloperPage from '../developer/DeveloperPage';
import DirectPurchasePage from '../directPurchase/DirectPurchasePage';
import ExportWorkflowsPage from '../exportWorkflows/ExportWorkflowsPage';
import GroupsPage from '../groups/GroupsPage';
import HomePage from '../HomePage';
import ImportWorkflowsPage from '../importWorkflows/ImportWorkflowsPage';
import InvoicesPage from '../invoices/InvoicesPage';
import LocationWizardsPage from '../locationWizards/LocationWizardsPage';
import LogsPage from '../logs/LogsPage';
import ManagerPage from '../manager/ManagerPage';
import Header from '../navigation/Header';
import UserMenu from '../navigation/UserMenu';
import ParametersPage from '../parameters/ParametersPage';
import PlansPage from '../plans/PlansPage';
import RolesPage from '../roles/RolesPage';
import SamplesPage from '../samples/SamplesPage';
import SampleTypeForm from '../sampleTypes/SampeTypeForm';
import SampleTypesPage from '../sampleTypes/SampleTypesPage';
import UserProfilePage from '../users/UserProfilePage';
import UsersPage from '../users/UsersPage';

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

            <Route exact path="/" render={(props) => <HomePage {...props} />} />

            {/* Left Hamburger Menu */}
            <Route exact path="/users" render={(props) => <UsersPage {...props} />} />
            <Route exact path="/sample_types" render={(props) => <SampleTypesPage {...props} />} />
            <Route exact path="/sample_types/new" render={(props) => <SampleTypeForm {...props} />} />
            <Route exact path="/announcements" render={(props) => <AnnouncementsPage {...props} />} />
            <Route exact path="/budgets" render={(props) => <BudgetsPage {...props} />} />
            <Route exact path="/object_types" render={(props) => <ContainersPage {...props} />} />
            <Route exact path="/direct_purchase" render={(props) => <DirectPurchasePage {...props} />} />
            <Route exact path="/import" render={(props) => <ImportWorkflowsPage {...props} />} />
            <Route exact path="/publish" render={(props) => <ExportWorkflowsPage {...props} />} />
            <Route exact path="/wizards" render={(props) => <LocationWizardsPage {...props} />} />
            <Route exact path="/logs" render={(props) => <LogsPage {...props} />} />
            <Route exact path="/parameters" render={(props) => <ParametersPage {...props} />} />
            <Route exact path="/roles" render={(props) => <RolesPage {...props} />} />
            <Route exact path="/groups" render={(props) => <GroupsPage {...props} />} />

            {/* Main Navigation tabs */}
            <Route exact path="/manager" render={(props) => <ManagerPage {...props} />} />
            <Route exact path="/launcher" render={(props) => <PlansPage {...props} />} />
            <Route exact path="/samples" render={(props) => <SamplesPage {...props} />} />
            <Route exact path="/developer" render={(props) => <DeveloperPage {...props} />} />
            <Route exact path="/designer" render={(props) => <DesignerPage {...props} />} />
            <Route exact path="/user" render={(props) => <UserMenu {...props} />} />

            {/* Right user Menu */}
            <Route exact path="/invoices" render={(props) => <InvoicesPage {...props} />} />
            <Route exact path="/users/:id" render={(props) => <UserProfilePage {...props} />} />

          </>
        </Switch>
      </div>
    </ThemeProvider>
  );
}
