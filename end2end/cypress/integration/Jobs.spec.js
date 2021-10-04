describe('/jobs', () => {
  beforeEach(() => {

    // stub API responses
    cy.fixture('jobs/jobCounts').then((json) => {
      cy.intercept('GET', '/jobs/counts', json)
    });

    cy.fixture('jobs/unassigned').then((json) => {
      cy.intercept('GET', '/jobs/unassigned', json)
    });

    cy.fixture('jobs/showJobOperations').then((json) => {
      // user handle wildcard variables
      cy.intercept('GET', '**/jobs/*/show*', json)
    });

    cy.login();
    cy.visit('/jobs');
  });

  it('Should load the correct URL', () => {

    cy.url().should('eq', `${Cypress.config().baseUrl}/jobs`);
  });

  it('should first render with unassigned jobs', () => {

    cy.get('[data-cy="job-states"]').within(() => {
      // Only yield inputs within nav

      // Verify selection indicator
      cy.get('[id=unassigned]').should('have.class', 'Mui-selected');
      cy.get('[id=assigned]').should('not.have.class', 'Mui-selected');
      cy.get('[id=finished]').should('not.have.class', 'Mui-selected');
    });

    cy.get('[data-cy="unassigned-jobs"]');

  });

  context('should accept user clicks to change tables using left navigation', () => {
    it('should select assigned tab', () => {

      cy.get('[id=assigned]')
        .should('not.have.class', 'Mui-selected')
        .click()
        .then(() => {
          // Verify selection indicator
          cy.get('[id=assigned]').should('have.class', 'Mui-selected');
          cy.get('[id=unassigned]').should('not.have.class', 'Mui-selected');
          cy.get('[id=finished]').should('not.have.class', 'Mui-selected');

          cy.get('[data-cy="assigned-jobs"]');
        });
      });

      it('should select finsihed tab', () => {
        cy.get('[id=finished]')
          .should('not.have.class', 'Mui-selected')
          .click()
          .then(() => {
            // Verify selection indicator
            cy.get('[id=finished]').should('have.class', 'Mui-selected');
            cy.get('[id=unassigned]').should('not.have.class', 'Mui-selected');
            cy.get('[id=assigned]').should('not.have.class', 'Mui-selected');
            cy.get('[data-cy="finished-jobs"]');
          });
      });
  });

  it('should remove operation from job', () => {

    // get the first row in the table then only objects within the row
    cy.get(`[role="row"]:first`).within(() => {
      cy.get(`[aria-label^="expand job"]:first`).click();
      cy.get(`[aria-label^="remove operation"]:first`).click();

    })
  });
});
