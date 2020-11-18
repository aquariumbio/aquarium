describe('/parameters', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/parameters');
    cy.contains('h1', 'Parameters');
  });
});
