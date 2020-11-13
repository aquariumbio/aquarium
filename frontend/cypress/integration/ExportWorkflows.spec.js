describe('/publish', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/publish');
    cy.contains('h1', 'Export Workflows');
  });
});
