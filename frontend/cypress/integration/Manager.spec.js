describe('/manager', function () {
  beforeEach(() => {
    cy.login();
  })

  afterEach(() => {
    cy.logout();
  })

  it('has place holder header', () => {
    cy.visit('/manager');
    cy.contains('h1', 'Manager');
  })

})