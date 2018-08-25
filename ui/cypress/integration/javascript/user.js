describe('Users', function() {

  it("Find the current user", function() {

    cy.login();  
    cy.designer();    

    cy.window().then(win => {
      let AQ = win.AQ;
      return AQ.User.current().then(user => {
         cy.wrap(user).its("id").should("be.above",0);
       })
    });

  });

});