
describe('Collections', function() {

  it('Makes new collections', function() {

    // New collection route
    cy.server()
    cy.route('PUT', '/collections/*').as('newCollection')  

    // Go to samples page
    cy.login();  
    cy.samples();

    // Make a new collection
    cy.get("#new-collection-button").click();
    cy.get("[data-new-collection-type=Stripwell]").click()  

    cy.wait(['@newCollection']).then(xhr => {

      const new_collection_id = xhr.response.body.id;
      cy.wrap(new_collection_id).should('be.above', 0)
      cy.url().should('equal', `http://localhost:3000/items/${new_collection_id}`)  

    })   

  })

})