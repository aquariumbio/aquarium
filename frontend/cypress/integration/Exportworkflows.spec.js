describe('/export_workflows', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/export_workflows');
    cy.contains('h1', 'Export Workflows');
  });
});
