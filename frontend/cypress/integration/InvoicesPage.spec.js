describe('/invoices', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/invoices');
    cy.contains('h1', 'Invoices');
  });
});
