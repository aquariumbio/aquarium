
Cypress.Commands.add("login", () => {

    cy.server()
      .route('GET', '/krill/debug/*').as('debugJob')  
      .route('POST', '/plans.json*').as('savePlan')
      .route('POST', '/json*').as('getBudget')  
      .route('GET', '/plans/folders*').as('getFolders')        
      .route('GET', '/items/make/5/1').as('newItem') 
      .route('POST', '/operations/manager_list').as('managerList')  

    cy.viewport(1500, 900)
      .visit('http://localhost:3000')
      .get('#session_login')
      .type('neptune')
      .get('#session_password')
      .type('aquarium')

    cy.contains('Sign in').click()
      .url().should('equal', 'http://localhost:3000/')
      .wait(100)

});

Cypress.Commands.add("logout", () => {

    cy.get('#user-specific-button').click()
    cy.get('#signout-button').click();
    cy.url().should('equal', 'http://localhost:3000/signout')

});

Cypress.Commands.add("samples", () => {

    cy.contains("Samples").click()
    cy.url().should('equal', 'http://localhost:3000/browser')
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






