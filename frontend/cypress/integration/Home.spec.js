describe('/', function () {
  beforeEach(() => {
    cy.login();
  })
  
  afterEach(() => {
    cy.logout();
  })

  it('has place holder header', () => {
    cy.visit('/');
    cy.contains('h1', 'Home');
  })

})