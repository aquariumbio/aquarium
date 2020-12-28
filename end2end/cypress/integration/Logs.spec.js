describe('/logs', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/logs');
    cy.contains('h1', 'Logs');
  });
});
