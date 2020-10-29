import Login from "./components/auth/Login"
import Home from "./components/Home";
import User from "./components/User";
import Plan from "./components/Plan";
import Manager from "./components/Manager";
import Samples from "./components/Samples";
import Developer from "./components/Developer";
import Designer from "./components/Designer";
import Logout from "./components/auth/Logout";

const routes = [
  {
    path: "/login",
    exact: true,
    component: Login
  },
  {
    path: "/logout",
    exact: true,
    component: Logout
  },
  {
    path: "/user",
    exact: true,
    component: User 
  },
  {
    path: "/designer",
    exact: true,
    component: Designer 
  },
  {
    path: "/plan",
    exact: true,
    component: Plan 
  },
  {
    path: "/manager",
    exact: true,
    component: Manager 
  },
  {
    path: "/samples",
    exact: true,
    component: Samples 
  },
  {
    path: "/developer",
    exact: true,
    component: Developer
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
  // {
  //   title: "Announcements",
  //   path: "/announcements",
  //   exact: true,
  //   component: <div>Announcements</div>
  // },
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
  //   path: "/containers",
  //   exact: true,
  //   component: <div>Containers</div>
  // },
  // {
  //   title: "Location Wizards",
  //   path: "/location_wizards",
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
    path: "/",
    forceRefresh: true,
    component: Home 

  },
];

export default routes;