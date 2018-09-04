Cypress.Commands.add("operation_status_is", (name,status) => {
    cy.get(`[data-operation-info=status][data-operation-name='${name}']`)
      .then(el => expect(el.text()).to.match(new RegExp(status)))
});
