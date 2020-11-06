describe('/import', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/import');
    cy.contains('h1', 'Import Workflows');
  });
});
