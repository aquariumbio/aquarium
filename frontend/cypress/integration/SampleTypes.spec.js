describe('Sample Types', () => {
  beforeEach(() => {
    cy.login();
  });

  describe('Sample Type page', () => {
    it('New Sample Types Form', () => {
      cy.visit('/sample_types');
      cy.get('div[name="sample-types-side-bar"]');
      cy.get('div[name="sample-types-main-container"]');
      cy.get('[data-cy="page-title"]');
      cy.get('[data-cy="edit_sample_type_btn"]');
      cy.get('[data-cy="new_sample_type_btn"]');
      cy.get('[data-cy="delete_sample_type_btn"]');
      cy.get('[data-cy="show-sample-type"]');
    });
  });

  describe.skip('Sample Type Form', () => {
    it('New Sample Types Form', () => {
      cy.visit('/sample_types/new');

      cy.contains('h1', 'Sample Type Definitions');

      cy.get('form[name="sampe_type_definition_form"]').within(() => {
        cy.contains('h4', 'Name');
        cy.get('input[name="sample_type_name"]').should(
          'have.attr',
          'placeholder',
          'Sample type name'
        );

        cy.contains('h4', 'Description');
        cy.get('input[name="sample_type_description"]').should(
          'have.attr',
          'placeholder',
          'Sample type description'
        );

        cy.contains('h4', 'Fields');
        cy.get('[data-cy=add_field]');
      });
    });
  });
});
