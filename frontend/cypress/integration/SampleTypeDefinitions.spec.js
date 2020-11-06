describe('/sample_type_definitions', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/sample_type_definitions');
    cy.contains('h1', 'Sample Type Definitions');
  });
});
