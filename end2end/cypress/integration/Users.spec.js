describe('Users', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/users');
    cy.contains('h1', 'Users');
  });


});
