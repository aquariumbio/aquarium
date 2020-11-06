describe('/sample_types', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/sample_types');
    cy.contains('h1', 'Sample Types');
  });
});
