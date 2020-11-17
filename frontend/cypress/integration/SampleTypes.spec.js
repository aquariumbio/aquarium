describe('/sample_types', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  it('has place holder header', () => {
    cy.visit('/sample_types');
    cy.contains('h1', 'Sample Types');
  });

  describe('Sample Type Form', () => {
    it('New Sample Types Form', () => {
      cy.visit('/sample_types/new');

      cy.contains('h1', 'Defining New Sample Type');

      cy.get('form[name="sampe_type_definition_form"]')
        .within(() => {
          cy.contains('h4', 'Name');
          cy.get('input[name="sample_type_name"]')
            .should('have.attr', 'placeholder', 'Sample type name');

          cy.contains('h4', 'Description');
          cy.get('input[name="sample_type_description"]')
            .should('have.attr', 'placeholder', 'Sample type description');
        });
    });
  });
});
