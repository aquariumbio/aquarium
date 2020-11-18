describe('/direct_purchase', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/direct_purchase');
    cy.contains('h1', 'Direct Purchase');
  });
});
