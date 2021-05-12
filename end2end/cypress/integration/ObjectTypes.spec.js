// Declare a global variable to store the id of a newly created object type so that we can refer to it in subsequent tests
var thisId

describe('/object_types', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  // object_type page
  it('object_type page', () => {
    cy.intercept('GET', '/object_types/new').as('newobject_type')

    cy.visit('/object_types');
    cy.contains('h1', 'Object Type Handlers');
    cy.get('[data-cy="new_object_type_btn"]').click().then(() => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', '/object_types/new');
    });
  });

  // new object_type page
  it('new object_type page', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/object_types/create?*`).as('newobject_type')

    cy.visit('/object_types/new');
    cy.contains('h1', 'New Object Type');
    cy.get('input[name="name"]')
      .type("name")
      .should("have.value", "name");

    cy.get('input[name="description"]')
      .type("description")
      .should("have.value", "description");

    cy.get('input[name="unit"]')
      .type("unit")
      .should("have.value", "unit");

    cy.get('input[name="handler"]')
      .type("handler")
      .should("have.value", "handler");

    cy.get('textarea[name="release_description"]')
      .type("release_description")
      .should("have.value", "release_description");

    // not worried about field names here
    // they are just sent to the backend as a json string

    cy.get("form").submit()
    cy.wait('@newobject_type').should(({ request, response }) => {
      // NOTE: per v2 you stay on the same page after creating a new object type.  This should probably be changed.
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', `/object_types/new`);

      // save the id of the object_type just created
      thisId = response.body.object_type['id']

      // TODO: add a test depending on what page we navigate to after creating a new object type
    })
  });

  // click edit object_type
  it('edit object_type', () => {
    cy.visit('/object_types');
    cy.get(`[data-cy="handler_handler"]`).click().then(() => {
      // wait 1 sec, there should be a better way to do this
      cy.wait(1000)

      cy.get(`[data-cy="edit_${thisId}"]`).click().then(() => {
        // wait for up to 3 seconds for the page to load
        cy.location('pathname', {timeout: 3000}).should('eq', `/object_types/${thisId}/edit`);
      });
    });
  });

  // edit the object_type
  it('edit object_type page', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/object_types/${thisId}/update?*`).as('editobject_type')

    cy.visit(`/object_types/${thisId}/edit`);
    cy.contains('h2', `Edit Object Type ${thisId}`);
    cy.get('input[name="name"]')
      .type("2")
      .should("have.value", "name2");

    cy.get('input[name="description"]')
      .type("2")
      .should("have.value", "description2");

    cy.get("form").submit()
    cy.wait('@editobject_type').should(({ request, response }) => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', `/object_types/${thisId}/edit`);

      // TODO: add a test depending on what page we navigate to after creating a new object type
    })
  });

  // delete object_type
  it('delete object_type', () => {
    cy.visit('/object_types');
    cy.get(`[data-cy="handler_handler"]`).click().then(() => {
      // wait 1 sec, there should be a better way to do this
      cy.wait(1000)

      cy.get(`[data-cy="delete_${thisId}"]`).click().then(() => {
        // wait for up to 3 seconds for the page to load
        cy.location('pathname', {timeout: 3000}).should('eq', `/object_types`);

        // handler should no longer exist (because this was the only object type with this handler)
        cy.get(`[data-cy="handler_handler"]`).should('not.exist');
      });
    });
  });
});
