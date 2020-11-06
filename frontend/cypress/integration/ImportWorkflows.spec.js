describe('/import_workflows', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/import_workflows');
    cy.contains('h1', 'Import Workflows');
  });
});
