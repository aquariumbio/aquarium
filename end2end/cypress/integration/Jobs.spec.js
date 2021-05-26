describe('/jobs', () => {

  beforeEach(() => {
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

});
