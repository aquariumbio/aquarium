describe('/wizards', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/wizards');
    cy.contains('h1', 'Location Wizards');
  });
});
