describe('/samples', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  // samples page
  it('samples page', () => {
    cy.intercept('GET', `${Cypress.env('API_URL')}/api/v3/samples?*`, { fixture: 'samples.json' });

    cy.visit('/samples');
  });

  // sample page
  it('sample page', () => {
    cy.intercept('GET', `${Cypress.env('API_URL')}/api/v3/samples/1?*`, { fixture: 'sample.json' });

    cy.visit('/samples/1');
  });

});
