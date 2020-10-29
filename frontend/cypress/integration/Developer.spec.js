describe('/developer', function () {
  beforeEach(() => {
    cy.login();
  })

  afterEach(() => {
    cy.logout();
  })

  it('has place holder header', () => {
    cy.visit('/developer');
    cy.contains('h1', 'Developer');
  })

})