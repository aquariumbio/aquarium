describe('Sample Types', () => {
  beforeEach(() => {
    cy.login();
  });

  describe('Sample Type page', () => {
    beforeEach(() => {
      cy.visit('/sample_types');
    });

    it('New Sample Types Form', () => {
      cy.get('div[name="sample-types-side-bar"]');
      cy.get('div[name="sample-types-main-container"]');
      cy.get('[data-cy="page-title"]');
      cy.get('[data-cy="edit_sample_type_btn"]');
      cy.get('[data-cy="new_sample_type_btn"]');
      cy.get('[data-cy="delete_sample_type_btn"]');
      cy.get('[data-cy="show-sample-type"]');
    });

    it('navigates to new form using new button', () => {
      cy.url().should('eq', `${Cypress.env('baseUrl')}/sample_types`);
      cy.get('[data-cy="new_sample_type_btn"]').click();
      cy.url().should('eq', `${Cypress.env('baseUrl')}/sample_types/new`);
    });

    it('navigates to new form using new button', () => {
      cy.url().should('eq', `${Cypress.env('baseUrl')}/sample_types`);
      cy.get('[data-cy="edit_sample_type_btn"]').click();
      cy.url().should('include', `${Cypress.env('baseUrl')}/sample_types/`).and('include', '/edit');
    });
  });

  describe('Sample Type Form', () => {
    context('New Sample Types Form', () => {
      it('inital form', () => {
        cy.visit('/sample_types/new');

        cy.get('[data-cy="form-header"]');

        cy.get('[data-cy="sampe-type-definition-form"]').within(() => {
          cy.contains('h4', 'Name');
          cy.get('[data-cy="sample-type-name-input"]');

          cy.contains('h4', 'Description');
          cy.get('[data-cy="sample-type-description-input"]');

          cy.get('[data-cy="add-new-field"]');
          cy.get('[data-cy="save-sample-type"]').should('have.attr', 'disabled');
          cy.get('[data-cy="back"]');
        });
      });

      it('back button navigation', () => {
        cy.visit('/sample_types/new');

        cy.url().should('eq', `${Cypress.env('baseUrl')}/sample_types/new`);

        cy.get('[data-cy="sampe-type-definition-form"]').within(() => {
          cy.get('[data-cy="back"]').click();
        });
        cy.url().should('eq', `${Cypress.env('baseUrl')}/sample_types`);
      });

      it('can create a new sample type with just name and description', () => {
        const randString = () => Math.random().toString(36).substr(7);
        const sampleTypeName = randString();
        const sampleTypeDescription = randString();

        cy.intercept(
          'POST',
          'http://localhost:3001/api/v3/sample_types/create',
          (req) => {
            req.reply((res) => {
              res.send({
                statusCode: 201,
                body: {
                  sample_type: {
                    name: sampleTypeName,
                    description: sampleTypeDescription,
                  },
                },
              });
            });
          }
        ).as('createSampleType');

        cy.visit('/sample_types/new');

        // Save disabled before inputs
        cy.get('[data-cy="save-sample-type"]')
          .should('have.attr', 'disabled');

        cy.get('[data-cy="sample-type-name-input"]')
          .type(sampleTypeName);

        // Save should still be disabled
        cy.get('[data-cy="save-sample-type"]')
          .should('have.attr', 'disabled');

        cy.get('[data-cy="sample-type-description-input"]')
          .type(sampleTypeDescription);

        cy.get('[data-cy="save-sample-type"]')
          .click();

        cy.get('[data-cy="alert-toast"]')
          .should('contain', 'saved');

        cy.wait(7000).then(() => {
          cy.get('[data-cy="alert-toast"]')
            .should('not.exist');
        });

      });

      it('shows error alert on failed create, duplicate name', () => {
        const randString = () => Math.random().toString(36).substr(7);
        const sampleTypeName = randString();
        const sampleTypeDescription = randString();

        cy.intercept(
          'POST',
          'http://localhost:3001/api/v3/sample_types/create',
          (req) => {
            req.reply((res) => {
              res.send({
                statusCode: 200,
                body: {
                  errors: {
                    name: ['has already been taken'],
                  },
                },
              });
            });
          }
        ).as('createSampleType');

        cy.visit('/sample_types/new');

        cy.get('[data-cy="sample-type-name-input"]').type(sampleTypeName);

        cy.get('[data-cy="sample-type-description-input"]').type(
          sampleTypeDescription
        );

        cy.get('[data-cy="save-sample-type"]').click();

        cy.get('[data-cy="alert-toast"]').should('contain', 'Error');

        cy.wait(7000).then(() => {
          cy.get('[data-cy="alert-toast"]').should('not.exist');
        });
      });
    });
  });
});
