describe('/samples', function () {
  beforeEach(() => {
    cy.login();
  })

  afterEach(() => {
    cy.logout();
  })

  it('has place holder header', () => {
    cy.visit('/samples');
    cy.contains('h1', 'Samples');
  })

})