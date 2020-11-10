describe('/groups', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/groups');
    cy.contains('h1', 'Groups');
  });
});
