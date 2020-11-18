describe('Plans', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/launcher');
    cy.contains('h1', 'Plans');
  });
});
