import LoginDialog from './components/auth/LoginDialog';
import Home from './components/HomePage';
import UserMenu from './components/navigation/UserMenu';
import PlansPage from './components/plans/PlansPage';
import ManagerPage from './components/manager/ManagerPage';
import SamplesPage from './components/samples/SamplesPage';
import DeveloperPage from './components/developer/DeveloperPage';
import DesignerPage from './components/designer/DesignerPage';
import AnnouncementsPage from './components/announcements/AnnouncementsPage';

const routes = [
  {
    path: '/login',
    exact: true,
    component: LoginDialog,
  },
  {
    path: '/user',
    exact: true,
    component: UserMenu,
  },
  {
    path: '/designer',
    exact: true,
    component: DesignerPage,
  },
  {
    path: '/plans',
    exact: true,
    component: PlansPage,
  },
  {
    path: '/manager',
    exact: true,
    component: ManagerPage,
  },
  {
    path: '/samples',
    exact: true,
    component: SamplesPage,
  },
  {
    path: '/developer',
    exact: true,
    component: DeveloperPage,
  },

  // {
  //   title: "Direct Purchase",
  //   path: "/direct_purchase",
  //   exact: true,
  //   component: <div>Direct Purchase</div>
  // },
  // {
  //   title: "Logs",
  //   path: "/logs",
  //   exact: true,
  //   component: <div>Logs</div>
  // },
  // {
  //   title: "Users",
  //   path: "/users",
  //   exact: true,
  //   component: <div>Users</div>
  // },
  // {
  //   title: "Groups",
  //   path: "/groups",
  //   exact: true,
  //   component: <div>Groups</div>
  // },
  // {
  //   title: "Roles",
  //   path: "/roles",
  //   exact: true,
  //   component: <div>Roles</div>
  // },
  {
    title: 'Announcements',
    path: '/announcements',
    exact: true,
    component: AnnouncementsPage,
  },
  // {
  //   title: "Budgets",
  //   path: "/budgets",
  //   exact: true,
  //   component: <div>Budgets</div>
  // },
  // {
  //   title: "Invoices",
  //   path: "/invoices",
  //   exact: true,
  //   component: <div>Innvoices</div>
  // },
  // {
  //   title: "Parameters",
  //   path: "/parameters",
  //   exact: true,
  //   component: <div>Parameters</div>
  // },
  // {
  //   title: "Sampel Type Definitions",
  //   path: "/sample_type_definitions",
  //   exact: true,
  //   component: <div>Sample Type Definitions</div>
  // },
  // {
  //   title: "Containers",
  //   path: "/object_types",
  //   exact: true,
  //   component: <div>Containers</div>
  // },
  // {
  //   title: "Location Wizards",
  //   path: "/wizards",
  //   exact: true,
  //   component: <div>Location Wizards</div>
  // },
  // {
  //   title: "Import Workflows",
  //   path: "/workflows/imports",
  //   exact: true,
  //   component: <div>Import Workflows</div>
  // },
  // {
  //   title: "Export Workflows",
  //   path: "/workflows/exports",
  //   exact: true,
  //   component: <div>Export Workflows</div>
  // },
  // {
  //   title: "Help",
  //   path: "/help",
  //   exact: true,
  //   component: <div>Help</div>
  // },

  {
    path: '/',
    forceRefresh: true,
    component: Home,
  },
];

export default routes;
