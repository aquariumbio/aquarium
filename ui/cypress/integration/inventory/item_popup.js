
describe('Item Popups', function() {

  it('Enables items to be edited', function() {

    cy.server()
    cy.route('GET', '/items/make/5/1').as('newItem')  

    // Go to samples page
    cy.login()
      .samples()

    // Make a new primer aliquot
    cy.get("[data-search-input=sample-type]").type("Primer") 
      .get("[data-search-button=search]").click()
      .get("[data-sample-header='First Primer']").click()
      .get("[data-sample-heading-button=actions]").click()
      .get("[data-sample-name='First Primer'][data-sample-action=new-item]")
      .trigger('mouseover') // This doesn't work, hence the "force" in the line after next
      .get("[data-sample-name='First Primer'][data-new-item-choice='Primer Aliquot']")
      .click({force: true})

    // Wait for new item and then test popup and search
    cy.wait(['@newItem'])
      .then(xhr => {
        const id = xhr.response.body.item.id
        cy.wrap(id)
          .should('be.above', 0)      
          .get(`[data-open-item-popup=${id}]`).click()       
          .test_item_popup(id)
          .get("[data-search-input=find-item]").type(`${id}`)
          .get("[data-search-button=find-item]").click()
          .test_item_popup(id)
      })

  })

})