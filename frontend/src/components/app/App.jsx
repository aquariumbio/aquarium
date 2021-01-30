/* disabling forbidden prop spreading for react-router-dom */
/* eslint-disable react/jsx-props-no-spreading */
import { createMuiTheme, makeStyles, ThemeProvider } from '@material-ui/core/styles';
import React, { useState } from 'react';
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
import UserForm from '../users/UserForm';
import SampleTypesPage from '../sampleTypes/SampleTypesPage';
import ObjectTypesPage from '../objectTypes/ObjectTypesPage';
import ObjectTypeForm from '../objectTypes/ObjectTypeForm';
import DirectPurchasePage from '../directPurchase/DirectPurchasePage';
import ExportWorkflowsPage from '../exportWorkflows/ExportWorkflowsPage';
import InvoicesPage from '../invoices/InvoicesPage';
import WizardsPage from '../wizards/WizardsPage';
import WizardForm from '../wizards/WizardForm';
import LogsPage from '../logs/LogsPage';
import Header from '../navigation/Header';
import UserProfilePage from '../users/UserProfilePage';
import SampleTypeDefinitionForm from '../sampleTypes/SampeTypeDefinitionForm';
import ImportWorkflowsPage from '../importWorkflows/ImportWorkflowsPage';
import GroupsPage from '../groups/GroupsPage';
import GroupPage from '../groups/GroupPage';
import GroupForm from '../groups/GroupForm';
import LoadingBackdrop from '../shared/LoadingBackdrop';
import AlertToast from '../shared/AlertToast';

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

  // AlertToast popup - initialize to "false" and manage in individual components
  const [alertProps, setAlertProps] = useState({});

  return (
    <>
      <AlertToast
        open={alertProps.open}
        severity={alertProps.severity}
        message={alertProps.message}
      />
      <LoadingBackdrop isLoading={isLoading} />
      <ThemeProvider theme={theme}>
        <div name="app-container" className={classes.container} data-cy="app-container">
          { /* Users cannot interact with the app if they do not have a token */
            !sessionStorage.getItem('token')
            && <Redirect to="/login" />
          }
          { /* TODO: REDIRECT TO PROFILE PAGE IF USER HAS NOT SIGNED AGREENEMTNS */ }

          <Switch>
            <Route path="/login" render={(props) => <LoginDialog setIsLoading={setIsLoading} {...props} />} />
            <>
              {/* Header should show on all pages except login */}
              <Header />

              <Route exact path="/" render={(props) => <HomePage setIsLoading={setIsLoading} {...props} />} />

              {/* Left Hamburger Menu */}
              <Route exact path="/users" render={(props) => <UsersPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/users/new" render={(props) => <UserForm setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />

              <Route exact path="/groups" render={(props) => <GroupsPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/groups/new" render={(props) => <GroupForm setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/groups/:id/show" render={(props) => <GroupPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/groups/:id/edit" render={(props) => <GroupForm setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />

              <Route exact path="/sample_types" render={(props) => <SampleTypesPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/sample_types/new" render={(props) => <SampleTypeDefinitionForm setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/sample_types/:id/edit" render={(props) => <SampleTypeDefinitionForm setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />

              <Route exact path="/announcements" render={(props) => <AnnouncementsPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />

              <Route exact path="/wizards" render={(props) => <WizardsPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/wizards/new" render={(props) => <WizardForm setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/wizards/:id/edit" render={(props) => <WizardForm setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />

              <Route exact path="/object_types" render={(props) => <ObjectTypesPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/object_types/new" render={(props) => <ObjectTypeForm setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/object_types/:id/edit" render={(props) => <ObjectTypeForm setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />

              <Route exact path="/direct_purchase" render={(props) => <DirectPurchasePage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/import" render={(props) => <ImportWorkflowsPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/publish" render={(props) => <ExportWorkflowsPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/logs" render={(props) => <LogsPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/parameters" render={(props) => <ParametersPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/roles" render={(props) => <RolesPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />

              {/* Main Navigation tabs */}
              <Route exact path="/manager" render={(props) => <ManagerPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/launcher" render={(props) => <PlansPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/samples" render={(props) => <SamplesPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/developer" render={(props) => <DeveloperPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/designer" render={(props) => <DesignerPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/user/profile" render={(props) => <UserMenu setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />

              {/* Right user Menu */}
              <Route exact path="/invoices" render={(props) => <InvoicesPage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />
              <Route exact path="/users/:id/profile" render={(props) => <UserProfilePage setIsLoading={setIsLoading} setAlertProps={setAlertProps} {...props} />} />

              {/* Redirect anything else to HOME (or a 404 page or something else) */}
              {/* TODO */}
            </>
          </Switch>
        </div>
      </ThemeProvider>
    </>
  );
}
