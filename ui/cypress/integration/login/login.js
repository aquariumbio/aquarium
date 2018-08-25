describe('Login', function() {

  it('Logs in and out', function() {

    cy.login();  
    cy.logout();

  })

});