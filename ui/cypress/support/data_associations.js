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
