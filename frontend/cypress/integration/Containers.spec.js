describe('/containers', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/containers');
    cy.contains('h1', 'Containers');
  });
});
