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

    // should have 3 cards
    cy.get(`[cy="sample-36319"]`).should('exist');
    cy.get(`[cy="sample-36317"]`).should('exist');
    cy.get(`[cy="sample-36316"]`).should('exist');
    cy.get(`[cy="sample-0"]`).should('not.exist');
  });

  // sample page
  it('sample page', () => {
    cy.intercept('GET', `${Cypress.env('API_URL')}/api/v3/samples/36319?*`, { fixture: 'sample.json' });

    cy.visit('/samples/36319');

    // should have 5 groups
    cy.get(`[cy="group-421"]`).should('have.text', '1 ng/µL Fragment Stock');
    cy.get(`[cy="group-295"]`).should('have.text', 'Fragment Stock');
    cy.get(`[cy="group-292"]`).should('have.text', 'Gel Slice');
    cy.get(`[cy="group-456"]`).should('have.text', '50 mL 0.8 Percent Agarose Gel in Gel Box');
    cy.get(`[cy="group-440"]`).should('have.text', 'Stripwell');
    cy.get(`[cy="group-0"]`).should('not.exist');

    // group 421 should have item 510028 (click on group to view)
    cy.get(`[cy="item-510028"]`).should('not.be.visible');
    cy.get(`[cy="group-421"]`).click().then(() => {
      cy.get(`[cy="item-510028"]`).should('be.visible');
    })

    // group 440 should have discarded item 36357 (click on group then on discarded toggle to view)
    cy.get(`[cy="item-36357"]`).should('not.be.visible');
    cy.get(`[cy="group-440"]`).click().then(() => {
      cy.get(`[cy="item-36357"]`).should('not.be.visible');
      cy.get(`[cy="toggle-440"]`).click().then(() => {
        cy.get(`[cy="item-36357"]`).should('be.visible');
      })
    })
  });

});
