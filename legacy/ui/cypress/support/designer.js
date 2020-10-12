Cypress.Commands.add("designer", () => {
  cy.contains("Designer")
    .click()
    .url().should('equal', 'http://localhost:3000/plans')
    .wait('@planOperationTypes')
});

Cypress.Commands.add("design_with", category => {
  cy.get('[data-sidebar=design]').click()
    .get("[data-design='Operation Types']").click()
    .get(`[data-operation-type-category='${category}']`).click()
});

Cypress.Commands.add("save_as", name => {
  cy.get("#plan-title-input")
    .clear()
    .type(name)
    .get("[data-action=Save]")
    .click()
    .wait(['@savePlan', '@getBudget', '@getFolders'])
    .then((xhrs) => {
      const id = xhrs[0].response.body.id
      cy.wrap(id).should('be.above', 0)
    })
    .get("#plan-editor-container")
    .scrollTo(0,0)
});

Cypress.Commands.add("launch", budget_name => {
  cy.get("[data-sidebar=launch]")
    .click()
    .get(`[data-invalid-plan]`)
    .should('not.be.visible')
    .get(`[data-sidebar-budget-checkbox='${budget_name}']`)
    .click()
    .get('[data-sidebar-action=submit]')
    .click()
});

Cypress.Commands.add("load_first_plan_in_folder", name => {
  cy.get('[data-sidebar=plans]')
    .click()
    .get(`[data-plan-folder='${name}']`)
    .click()
    .get(`[data-plan-folder='${name}'][data-load-plan]`)
    .first()
    .click()
});

Cypress.Commands.add("operation_status_is", (name,status) => {
    cy.get(`[data-operation-info=status][data-operation-name='${name}']`)
      .then(el => expect(el.text()).to.match(new RegExp(status)))
});

Cypress.Commands.add("set_operation_status", (name,status) => {
    cy.get(`[data-operation-info=status][data-operation-name='${name}']`)
      .click()
      if (status == "error") {
        cy.get(`[ng-mousedown="cancel_operation(op)"]`)
        .click()
      } else {
        cy.get(`[ng-mousedown="change_status(op,'${status}')"]`)
        .click()
      }
      cy.get(".md-confirm-button")
      .click()
      .wait(1000)
      .operation_status_is(name,status)
});

Cypress.Commands.add("add_operation", name => {
  cy.get(`[data-add-operation-type='${name}']`)
    .click()
});

Cypress.Commands.add("choose_input", (name,index) => {
  cy.get(`[data-input-of='${name}'][data-input-number=${index}]`)
    .click()
});

Cypress.Commands.add("choose_output", (name,index) => {
  cy.get(`[data-output-of='${name}'][data-output-number=${index}]`)
    .click({force: true})
});

Cypress.Commands.add("choose_successor", name => {
  cy.get(`[data-successor='${name}']`)
    .click()
});

Cypress.Commands.add("choose_predecessor", name => {
  cy.get(`[data-predecessor='${name}']`)
    .click()
});

Cypress.Commands.add("choose_operation_box", name => {
  cy.get(`[data-operation-box='${name}']`)
    .click()
});

Cypress.Commands.add("associate_sample_to_output", (output_name,sample_name) => {
  cy.get(`[data-io-type=output][data-io-name='${output_name}']`)
    .type(sample_name)
  cy.contains(sample_name)
    .click()
    .wait(1000)
});

Cypress.Commands.add("associate_sample_to_input", (input_name,sample_name) => {
  cy.get(`[data-io-type=input][data-io-name='${input_name}']`)
    .type(sample_name)
  cy.contains(sample_name)
    .click()
    .wait(1000)
});

Cypress.Commands.add("choose_operation_box", name => {
  cy.get(`[data-operation-box='${name}']`)
    .click()
});

Cypress.Commands.add("define_parameter", (op_name,param,value) => {
  cy.get(`[data-operation-box='${op_name}']`)
    .click()
    .get(`[data-parameter='${param}']`)
    .type(value)
});

Cypress.Commands.add("choose_second_item", () => {
  cy.get(`[data-item-number=1][data-item-list-part=checkbox]`)
    .click()
});

Cypress.Commands.add("open_second_item", () => {
  cy.get(`[data-item-number=1][data-item-list-part=item]`)
    .click()
});

Cypress.Commands.add("get_first_item_checkbox", () => {
  cy.get(`[data-item-number=0][data-item-list-part=checkbox]`)
});
