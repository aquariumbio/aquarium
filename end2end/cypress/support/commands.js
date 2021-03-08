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

Cypress.Commands.add('login', () => {
  const login = 'neptune';
  const password = 'aquarium';

  cy.request({
    method: 'POST',
    url: `http://${Cypress.env(BASE_API)}/api/v3/token/create?login=${login}&password=${password}`,
  })
    .then((resp) => {
      window.localStorage.setItem('token', resp.body.token);
    });
});

Cypress.Commands.add('logout', () => {
  const token = window.localStorage.getItem('token');

  cy.request({
    method: 'POST',
    url: `http://${Cypress.env(BASE_API)}/api/v3/token/delete?token=${token}`,
  })
    // eslint-disable-next-line no-unused-vars
    .then((resp) => {
      window.localStorage.clear();
    });
});
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
