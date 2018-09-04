
Cypress.Commands.add("login", () => {

    cy.viewport(1500, 900)

    cy.visit('http://localhost:3000')

    cy.get('#session_login')
      .type('neptune')

    cy.get('#session_password')
      .type('aquarium')

    cy.contains('Sign in').click()
    cy.url().should('equal', 'http://localhost:3000/')
    cy.wait(100)  

});

Cypress.Commands.add("logout", () => {

    cy.get('#user-specific-button').click()
    cy.get('#signout-button').click();
    cy.url().should('equal', 'http://localhost:3000/signout')

});

Cypress.Commands.add("designer", () => {

    cy.contains("Designer").click()
    cy.url().should('equal', 'http://localhost:3000/plans')
    cy.wait(1000) 

});

Cypress.Commands.add("samples", () => {

    cy.contains("Samples").click()
    cy.url().should('equal', 'http://localhost:3000/browser')
    cy.wait(1000) 

});

Cypress.Commands.add("manager", () => {

    cy.contains("Manager").click()
    cy.url().should('equal', 'http://localhost:3000/operations')
    cy.wait(1000) 

});

Cypress.Commands.add("ignore_bootstrap_error", () => {
    cy.on('uncaught:exception', (err, runnable) => {
      // This error is thrown by bootstrap.js. It can be fixed following
      // this advise: https://stackoverflow.com/questions/35539374/bootstrap-dropdown-jquery-uncaught-error-syntax-error-unrecognized-expression
      // but we don't yet have a way to automtically patch this file while installing javascripts with bower.
      expect(err.message).to.include('unrecognized expression: #')
      done()
      return false
    }) 
});






