describe('/designer', function () {
  beforeEach(() => {
    cy.login();
  })

  afterEach(() => {
    cy.logout();
  })

  it('has place holder header', () => {
    cy.visit('/designer');
    cy.contains('h1', 'Designer');
  })

})