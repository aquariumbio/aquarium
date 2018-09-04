
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


Cypress.Commands.add("data_association", (parent_class, parent_id, key, value) => {

  cy.window().then(win => {
    let AQ = win.AQ;
    AQ.DataAssociation.where({parent_class: parent_class, parent_id: parent_id, key: key})
      .then(das => {
        expect(das).to.have.length(1);
        expect(das[0].value).to.equal(value)
      })
  })

})

Cypress.Commands.add("data_association_not_present", (parent_class, parent_id, key) => {

  cy.window().then(win => {
    let AQ = win.AQ;
    AQ.DataAssociation.where({parent_class: parent_class, parent_id: parent_id, key: key})
      .then(das => {
        expect(das).to.have.length(0);
      })
  })

})

Cypress.Commands.add("test_item_popup", (id) => {

      // make sure basic info is present
    cy.get(`[data-popup-title-item-id=${id}]`)
      .get(`[data-popup-title-container-name='Primer Aliquot']`)
      .get(`[data-popup-title-sample-name='First Primer']`)

      // location
      .get(`[data-item-id=${id}][data-item-popup-action=delete]`).click()
      .get(`[data-item-id=${id}][data-item-popup-action=restore]`).click()          
      .get(`[data-item-id=${id}][data-item-popup-input=location]`).then(input => {
        expect(input.val()).to.match(/M20\.*\.*\.*/)
      })

      // make a data association
      .get(`[data-item-id=${id}][data-item-popup-action=new-data-association]`).click() 
      .get(`[data-association-parent-id=${id}][data-association-index=0][data-association-input=key]`)
      .clear()
      .type("hello") 
      .get(`[data-association-parent-id=${id}][data-association-index=0][data-association-input=value]`)
      .clear()
      .type("world")
      .get(`[data-association-parent-id=${id}][data-association-index=0][data-association-action=save]`)
      .click()
      .data_association("Item", id, "hello", "world")

      // delete a data association and check its gone          
      .get(`[data-association-parent-id=${id}][data-association-index=0][data-association-action=delete]`)
      .click()
      .data_association_not_present("Item", id, "hello")  

      // close the popup
      .get(`[data-item-id=${id}][data-item-popup-action=close]`).click()

})

