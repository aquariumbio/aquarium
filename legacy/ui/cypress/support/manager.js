Cypress.Commands.add("manager", () => {
  cy.contains("Manager")
    .click()
    .url()
    .should('equal', 'http://localhost:3000/operations')
    .wait(1000) 
});

Cypress.Commands.add("manager_category", name => {
  cy.get(`[data-category-choice='${name}']`)
    .click()
});

Cypress.Commands.add("manager_operation_list", (name, status) => {
  cy.get(`[data-operation-type-name='${name}'][data-status=${status}]`)
    .click()
    .wait('@managerList')
});

Cypress.Commands.add("manager_check_last_operation", () => {
  cy.get(`[data-operation-checkbox]`)
    .last()
    .click()
});

Cypress.Commands.add("manager_check_first_operation", () => {
  cy.get(`[data-operation-checkbox]`)
    .first()
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
