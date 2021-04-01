var thisId
var userId

describe('/groups', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  // group page
  it('group page', () => {
    cy.intercept('GET', '/groups/new').as('newgroup')

    cy.visit('/groups');
    cy.contains('h1', 'All');
    cy.get('[data-cy="new_group_btn"]').click().then(() => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', '/groups/new');
    });
  });

  // new group page
  it('new group page', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/groups/create`).as('newgroup')

    cy.visit('/groups/new');
    cy.contains('h1', 'New Group');
    cy.get('input[name="name"]')
      .type("name")
      .should("have.value", "name");

    cy.get('input[name="description"]')
      .type("description")
      .should("have.value", "description");

    cy.get("form").submit()
    cy.wait('@newgroup').should(({ request, response }) => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', `/groups`);

      // save the id of the group just created
      thisId = response.body.group['id']

      // show group link should exist
      cy.get(`[data-cy="show_${thisId}"]`).should('exist');
    })
  });

  // click edit group
  it('edit group', () => {
    cy.visit('/groups');
    cy.get(`[data-cy="edit_${thisId}"]`).click().then(() => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', `/groups/${thisId}/edit`);
    });
  });

  // edit the group
  it('edit group page', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/groups/${thisId}/update`).as('editgroup')

    cy.visit(`/groups/${thisId}/edit`);
    cy.contains('h2', `Edit Group ${thisId}`);
    cy.get('input[name="name"]')
      .type("2")
      .should("have.value", "name2");

    cy.get('input[name="description"]')
      .type("2")
      .should("have.value", "description2");

    cy.get("form").submit()
    cy.wait('@editgroup').should(({ request, response }) => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', `/groups`);

      // show group link should exist
      cy.get(`[data-cy="show_${thisId}"]`).should('exist');
    })
  });

  // visit the group detail page
  it('visit group page', () => {
    cy.intercept('POST', `http://localhost:3001/api/v3/groups/${thisId}/show`).as('showgroup')

    cy.visit(`/groups/${thisId}/show`);
    cy.contains('div', 'Add Member');
  });

  // add member to the group
  it('add member', () => {
    userId = window.localStorage.getItem('userId')

    // add member
    cy.visit(`/groups/${thisId}/show`);
    // click on dropdown
    cy.get("#user-id-input").click().then(() => {
      // click on option
      cy.get(`[data-value="${userId}"]`).click().then(() => {
        cy.contains('div', 'neptune');
      })
    })

  });

  // remove member from the group
  it('remove member', () => {
    userId = window.localStorage.getItem('userId')

    cy.visit(`/groups/${thisId}/show`);
    // remove member
    cy.get(`[data-cy="remove_${userId}"]`).click().then(() => {
      // the member should no longer exist
      cy.get(`[data-cy="remove_${userId}"]`).should('not.exist');
    });
  });

  // delete group
  it('delete group', () => {
    cy.visit('/groups');
    // delete group
    cy.get(`[data-cy="delete_${thisId}"]`).click().then(() => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', `/groups`);

      // group should no longer exist
      cy.get(`[data-cy="delete_${thisId}"]`).should('not.exist');
    });
  });
});
