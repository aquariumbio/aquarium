Cypress.Commands.add("manager_category", name => {
  cy.get(`[data-category-choice='${name}']`)
    .click()
});

Cypress.Commands.add("manager_operation_list", (name, status) => {
  cy.route('POST', '/operations/manager_list').as('managerList')  
    .get(`[data-operation-type-name='${name}'][data-status=${status}]`)
    .click()
    .wait('@managerList')
});

Cypress.Commands.add("manager_check_last_operation", () => {
  cy.get(`[data-operation-checkbox]`)
    .last()
    .click()
});

Cypress.Commands.add("manager_action", action => {
  cy.get(`[data-manager-action='${action}']`)
    .click()
});

Cypress.Commands.add("manager_job_action", action => {
  cy.get(`[data-manager-job-action='${action}']`)
    .last()
    .click()
});
