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


Cypress.Commands.add("samples_search_item", (id) => {
      cy.get(`[ng-model="views.search.item_id"]`)
      .type(id)
      .get(`[ng-click="item_search()"]`)
})
