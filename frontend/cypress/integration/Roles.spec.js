describe('/roles', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/roles');
    cy.contains('h1', 'Roles');
  });
});
