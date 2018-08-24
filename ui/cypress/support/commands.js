
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

Cypress.Commands.add("designer", () => {

    cy.contains("Designer").click()
    cy.url().should('equal', 'http://localhost:3000/plans')
    cy.wait(1000) 

});