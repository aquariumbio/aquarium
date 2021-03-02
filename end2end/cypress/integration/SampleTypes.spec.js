describe('/sample_types', () => {
  beforeEach(() => {
    cy.login();
  });

  describe('Sample Type page', () => {
    it('has expected components', () => {
      cy.visit('/sample_types');

      cy.get('div[name="sample-types-side-bar"]');
      cy.get('div[name="sample-types-main-container"]');
      cy.get('[data-cy="page-title"]');
      cy.get('[data-cy="edit_sample_type_btn"]');
      cy.get('[data-cy="new_sample_type_btn"]');
      cy.get('[data-cy="delete_sample_type_btn"]');
      cy.get('[data-cy="show-sample-type"]');
    });

    it('navigates to new form using new button', () => {
      cy.visit('/sample_types');

      cy.url().should('eq', `${Cypress.config().baseUrl}/sample_types`);
      cy.get('[data-cy="new_sample_type_btn"]').click();
      cy.url().should('eq', `${Cypress.config().baseUrl}/sample_types/new`);
    });

    it('edit button is disabled when no sample types', () => {
      cy.intercept(
        'GET',
        `${Cypress.env('apiUrl')}/sample_types`,
        (req) => {
          req.reply((res) => {
            res.send({
              statusCode: 200,
              body: {
                sample_types: [],
                first: {}
              },
            });
          });
        }
      ).as('getSampleTypes');
      cy.visit('/sample_types');

      cy.get('[data-cy="edit_sample_type_btn"]').should('have.attr', 'aria-disabled', 'true');
    });
  });

  it('has place holder header', () => {
    cy.visit('/sample_types');
    cy.contains('h1', 'Sample Types');
  });
});
