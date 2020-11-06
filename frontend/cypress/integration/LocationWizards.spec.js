describe('/location_wizards', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/location_wizards');
    cy.contains('h1', 'Location Wizards');
  });
});
