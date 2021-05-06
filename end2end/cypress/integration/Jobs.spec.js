describe('/jobs', () => {
  before(() => {
    cy.login();
  });

  it('should first render with unassigned jobs', () => {
    cy.visit('/jobs');

    cy.get('[id=jobs-vertical-nav]').within(() => {
      // Only yield inputs within nav

      // Verify selection indicator
      cy.get('[id=unassigned]').should('have.class', 'Mui-selected');
      cy.get('[id=assigned]').should('not.have.class', 'Mui-selected');
      cy.get('[id=finished]').should('not.have.class', 'Mui-selected');
    });

    cy.get('[id=unassigned-jobs-table]');

  });

  it('should accept user clicks to change tables using left navigation', () => {
    // Select assigned
    cy.get('[id=assigned]')
      .should('not.have.class', 'Mui-selected')
      .click()
      .then(() => {
        // Verify selection indicator
        cy.get('[id=assigned]').should('have.class', 'Mui-selected');
        cy.get('[id=unassigned]').should('not.have.class', 'Mui-selected');
        cy.get('[id=finished]').should('not.have.class', 'Mui-selected');

        cy.get('[id=assigned-jobs-table]');
        expect
      });

    // Select finished
    cy.get('[id=finished]')
      .should('not.have.class', 'Mui-selected')
      .click()
      .then(() => {
        // Verify selection indicator
        cy.get('[id=finished]').should('have.class', 'Mui-selected');
        cy.get('[id=unassigned]').should('not.have.class', 'Mui-selected');
        cy.get('[id=assigned]').should('not.have.class', 'Mui-selected');

        cy.get('[id=finished-jobs-table]');
      });
  });

});
