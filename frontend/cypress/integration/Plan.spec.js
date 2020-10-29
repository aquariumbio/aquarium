describe('/plan', function () {
  beforeEach(() => {
    cy.login();
  })

  afterEach(() => {
    cy.logout();
  })

  it('has place holder header', () => {
    cy.visit('/plan');
    cy.contains('h1', 'Plan');
  })

})