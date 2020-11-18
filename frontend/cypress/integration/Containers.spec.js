describe('/object_types', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/object_types');
    cy.contains('h1', 'Containers');
  });
});
