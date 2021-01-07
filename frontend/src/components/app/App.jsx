/* disabling forbidden prop spreading for react-router-dom */
/* eslint-disable react/jsx-props-no-spreading */
import { createMuiTheme, makeStyles, ThemeProvider } from '@material-ui/core/styles';
import React from 'react';
// eslint-disable-next-line object-curly-newline
import { Redirect, Route, Switch } from 'react-router-dom';

import AnnouncementsPage from '../announcements/AnnouncementsPage';
import LoginDialog from '../auth/LoginDialog';
import UserMenu from '../navigation/UserMenu';
import ManagerPage from '../manager/ManagerPage';
import PlansPage from '../plans/PlansPage';
import SamplesPage from '../samples/SamplesPage';
import HomePage from '../HomePage';
import DeveloperPage from '../developer/DeveloperPage';
import DesignerPage from '../designer/DesignerPage';
import ParametersPage from '../parameters/ParametersPage';
import RolesPage from '../roles/RolesPage';
import UsersPage from '../users/UsersPage';
import SampleTypesPage from '../sampleTypes/SampleTypesPage';
import BudgetsPage from '../budgets/BudgetsPage';
import ObjectTypesPage from '../objectTypes/ObjectTypesPage';
import ObjectTypeForm from '../objectTypes/ObjectTypeForm';
import DirectPurchasePage from '../directPurchase/DirectPurchasePage';
import ExportWorkflowsPage from '../exportWorkflows/ExportWorkflowsPage';
import InvoicesPage from '../invoices/InvoicesPage';
import LocationWizardsPage from '../locationWizards/LocationWizardsPage';
import LogsPage from '../logs/LogsPage';
import Header from '../navigation/Header';
import UserProfilePage from '../users/UserProfilePage';
import SampleTypeDefinitionForm from '../sampleTypes/SampeTypeDefinitionForm';
import ImportWorkflowsPage from '../importWorkflows/ImportWorkflowsPage';
import GroupsPage from '../groups/GroupsPage';

const useStyles = makeStyles(() => ({
  root: {
    height: '100vh',
    overflow: 'scroll',
  },
}));
const theme = createMuiTheme({
  palette: {
    primary: {
      light: '#5290c1',
      main: '#136390',
      dark: '#003962',
      contrastText: '#fff',
    },
  },
  overrides: {
    MuiDivider: {
      root: {
        margin: '16px 0px',
      },
    },
  },
});

export default function App() {
  const classes = useStyles();

  return (
    <ThemeProvider theme={theme}>
      <div name="app-container" className={classes.container} data-cy="app-container">
        { /* Users cannot interact with the app if they do not have a token */
          !sessionStorage.getItem('token')
          && <Redirect to="/login" />
        }
        { /* TODO: REDIRECT TO PROFILE PAGE IF USER HAS NOT SIGNED AGREENEMTNS */ }

        <Switch>
          <Route path="/login" render={(props) => <LoginDialog {...props} />} />
          <>
            {/* Header should show on all pages except login */}
            <Header />

            <Route exact path="/" render={(props) => <HomePage {...props} />} />

            {/* Left Hamburger Menu */}
            <Route exact path="/users" render={(props) => <UsersPage {...props} />} />

            <Route exact path="/sample_types" render={(props) => <SampleTypesPage {...props} />} />
            <Route exact path="/sample_types/new" render={(props) => <SampleTypeDefinitionForm {...props} />} />
            <Route exact path="/sample_types/:id/edit" render={(props) => <SampleTypeDefinitionForm {...props} />} />

            <Route exact path="/announcements" render={(props) => <AnnouncementsPage {...props} />} />
            <Route exact path="/budgets" render={(props) => <BudgetsPage {...props} />} />

            <Route exact path="/object_types" render={(props) => <ObjectTypesPage {...props} />} />
            <Route exact path="/object_types/new" render={(props) => <ObjectTypeForm {...props} />} />
            <Route exact path="/object_types/:id/edit" render={(props) => <ObjectTypeForm {...props} />} />

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

            {/* Redirect anything else to HOME (or a 404 page or something else) */}
            {/* TODO */}
          </>
        </Switch>
      </div>
    </ThemeProvider>
  );
}
