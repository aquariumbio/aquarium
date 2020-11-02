// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
Cypress.Commands.add("login", () => {
  let login = 'marikoa';
  let password = 'MtXzwmLYTDq5Gucr';

  cy.request({
    method: 'POST',
    url: `http://localhost:3001/api/v3/user/sign_in?login=${login}&password=${password}`
  })
  .then((resp) => {
    window.localStorage.setItem('token', resp.body.data.token)
  })
})
Cypress.Commands.add("logout", () => {
  let token = window.localStorage.getItem('token');

  cy.request({
    method: 'POST',
    url: `http://localhost:3001/api/v3/user/sign_out?token=${token}`
  })
  .then((resp) => {
    window.localStorage.clear();
  })
})
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })
