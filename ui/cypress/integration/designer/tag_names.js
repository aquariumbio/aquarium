describe('Tag names', function() {

  it('Assigns tag ids', function() {

    cy.login();  
    cy.designer();

    // Click on sidebar buttons
    cy.get('[data-sidebar=plans]').click()
    cy.get('[data-sidebar=design]').click()
    cy.get('[data-sidebar=node]').click()
    cy.get('[data-sidebar=io]').click()    
    cy.get('[data-sidebar=launch]').click()    

    // Check design sub-menus. Note that the sub-menues are
    // regenerated each time a sidebar button is clicked, 
    // so this is also testing that the submenu ids are
    // still getting made correctly (without accumlating old ids)
    cy.get('[data-sidebar=design]').click()
    cy.get('[data-design=System_Templates]').click()
    cy.get('[data-design=Your_Templates]').click()
    cy.get('[data-design=Operation_Types]').click()

    cy.get("[data-operation-type-category='Basic Cloning']").click()

    cy.get("[data-add-operation-type='Make PCR Fragment']").click().click().click()

    cy.get("[data-operation-box='Make PCR Fragment']").each(box => {
      cy.wrap(box).click()
    })

  });
  
})

