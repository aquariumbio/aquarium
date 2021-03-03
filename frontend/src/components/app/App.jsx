/* disabling forbidden prop spreading for react-router-dom */
/* eslint-disable react/jsx-props-no-spreading */
import { createMuiTheme, makeStyles, ThemeProvider } from '@material-ui/core/styles';
import React, { useState } from 'react';
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
import ContainersPage from '../containers/ContainersPage';
import DirectPurchasePage from '../directPurchase/DirectPurchasePage';
import ExportWorkflowsPage from '../exportWorkflows/ExportWorkflowsPage';
import InvoicesPage from '../invoices/InvoicesPage';
import LocationWizardsPage from '../locationWizards/LocationWizardsPage';
import LogsPage from '../logs/LogsPage';
import Header from '../navigation/Header';
import UserProfilePage from '../users/UserProfilePage';
import SampleTypeDefinitionForm from '../sampleTypes/SampeTypeForm';
import ImportWorkflowsPage from '../importWorkflows/ImportWorkflowsPage';
import GroupsPage from '../groups/GroupsPage';
import LoadingSpinner from '../shared/LoadingSpinner';

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

  // isLoading overlay - initialize to "false" and manage in individual components
  const [isLoading, setIsLoading] = useState(false);

  return (
    <>
      <ThemeProvider theme={theme}>
        <div name="app-container" className={classes.container} data-cy="app-container">
          <LoadingSpinner isLoading={isLoading} />

          { /* Users cannot interact with the app if they do not have a token */
            !localStorage.getItem('token') &&
            <Redirect to="/login" />
          }
          { /* TODO: REDIRECT TO PROFILE PAGE IF USER HAS NOT SIGNED AGREEMENTS */ }

          <Switch>
            <Route path="/login" render={(props) => <LoginDialog setIsLoading={setIsLoading} {...props} />} />
            <>
              {/* Header should show on all pages except login */}
              <Header />

              <Route exact path="/" render={(props) => <HomePage setIsLoading={setIsLoading} {...props} />} />

              {/* Left Hamburger Menu */}
              <Route exact path="/users" render={(props) => <UsersPage setIsLoading={setIsLoading} {...props} />} />

              <Route exact path="/sample_types" render={(props) => <SampleTypesPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/sample_types/new" render={(props) => <SampleTypeDefinitionForm setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/sample_types/:id/edit" render={(props) => <SampleTypeDefinitionForm setIsLoading={setIsLoading} {...props} />} />

              <Route exact path="/announcements" render={(props) => <AnnouncementsPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/budgets" render={(props) => <BudgetsPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/object_types" render={(props) => <ContainersPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/direct_purchase" render={(props) => <DirectPurchasePage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/import" render={(props) => <ImportWorkflowsPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/publish" render={(props) => <ExportWorkflowsPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/wizards" render={(props) => <LocationWizardsPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/logs" render={(props) => <LogsPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/parameters" render={(props) => <ParametersPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/roles" render={(props) => <RolesPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/groups" render={(props) => <GroupsPage setIsLoading={setIsLoading} {...props} />} />

              {/* Main Navigation tabs */}
              <Route exact path="/manager" render={(props) => <ManagerPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/launcher" render={(props) => <PlansPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/samples" render={(props) => <SamplesPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/developer" render={(props) => <DeveloperPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/designer" render={(props) => <DesignerPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/user" render={(props) => <UserMenu setIsLoading={setIsLoading} {...props} />} />

              {/* Right user Menu */}
              <Route exact path="/invoices" render={(props) => <InvoicesPage setIsLoading={setIsLoading} {...props} />} />
              <Route exact path="/users/:id" render={(props) => <UserProfilePage setIsLoading={setIsLoading} {...props} />} />

              {/* TODO: If no route matches redirect to home page */}
            </>
          </Switch>
        </div>
      </ThemeProvider>
    </>
  );
}
