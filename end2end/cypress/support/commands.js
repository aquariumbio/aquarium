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
  const login = 'test_user';
  const password = 'aquarium123';

  cy.request({
    method: 'POST',
    url: `${Cypress.env('API_URL')}/api/v3/token/create?login=${login}&password=${password}`,
  })
    .then((resp) => {
      window.localStorage.setItem('token', resp.body.token);
      window.localStorage.setItem('userId', resp.body.user.id);
    });
});

Cypress.Commands.add('logout', () => {
  const token = window.localStorage.getItem('token');

  cy.request({
    method: 'POST',
    url: `${Cypress.env('API_URL')}/api/v3/token/delete?token=${token}`,
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
