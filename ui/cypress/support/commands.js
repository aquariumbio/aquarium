
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