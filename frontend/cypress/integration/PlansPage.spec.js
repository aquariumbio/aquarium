describe('/plans', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/plans');
    cy.contains('h1', 'Plans');
  });
});
