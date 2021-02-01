describe('Sample Types', () => {
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

    it.only('edit button is disabled when no sample types', () => {
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

  describe('New Sample Types Form', () => {
    it('inital form', () => {
      cy.visit('/sample_types/new');

      cy.get('[data-cy="form-header"]');

      cy.get('[data-cy="sampe-type-definition-form"]').within(() => {
        cy.contains('h4', 'Name');
        cy.get('[data-cy="sample-type-name-input"]');

        cy.contains('h4', 'Description');
        cy.get('[data-cy="sample-type-description-input"]');

        cy.get('[data-cy="add-new-field"]');
        cy.get('[data-cy="save-sample-type"]').should(
          'have.attr',
          'disabled'
        );
        cy.get('[data-cy="back"]');
      });
    });

    it('back button navigation', () => {
      cy.visit('/sample_types/new');

      cy.url().should('eq', `${Cypress.config().baseUrl}/sample_types/new`);

      cy.get('[data-cy="sampe-type-definition-form"]').within(() => {
        cy.get('[data-cy="back"]').click();
      });
      cy.url().should('eq', `${Cypress.config().baseUrl}/sample_types`);
    });

    it('can create a new sample type with just name and description', () => {
      const randString = () => Math.random().toString(36).substr(7);
      const sampleTypeName = randString();
      const sampleTypeDescription = randString();

      cy.intercept(
        'POST',
        `${Cypress.env('apiUrl')}/sample_types/create`,
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
      cy.get('[data-cy="save-sample-type"]').should('have.attr', 'disabled');

      cy.get('[data-cy="sample-type-name-input"]').type(sampleTypeName);

      // Save should still be disabled
      cy.get('[data-cy="save-sample-type"]').should('have.attr', 'disabled');

      cy.get('[data-cy="sample-type-description-input"]').type(
        sampleTypeDescription
      );

      cy.get('[data-cy="save-sample-type"]').click();

      cy.get('[data-cy="alert-toast"]').should('contain', 'saved');

      cy.wait(7000).then(() => {
        cy.get('[data-cy="alert-toast"]').should('not.exist');
      });
    });

    it('shows error alert on failed create, duplicate name', () => {
      const randString = () => Math.random().toString(36).substr(7);
      const sampleTypeName = randString();
      const sampleTypeDescription = randString();

      cy.intercept(
        'POST',
        `${Cypress.env('apiUrl')}/sample_types/create`,
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
