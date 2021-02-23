var thisId

describe('/users', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  // user page
  it('user page', () => {
    cy.intercept('GET', '/users/new').as('newuser')

    cy.visit('/users');
    cy.contains('h1', 'All');
    cy.get('[data-cy="new_user_btn"]').click().then(() => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', '/users/new');
    });
  });

  // new user page
  it('new user page', () => {
    cy.intercept('POST', 'http://localhost:3001/api/v3/users/create').as('newuser')

    cy.visit('/users/new');
    cy.contains('h1', 'New User');
    cy.get('input[name="name"]')
      .type("name")
      .should("have.value", "name");

    cy.get('input[name="login"]')
      .type("login")
      .should("have.value", "login");

    cy.get('input[name="password"]')
      .type("aquarium123")
      .should("have.value", "aquarium123");

    cy.get("form").submit()
    cy.wait('@newuser').should(({ request, response }) => {
      expect(response.statusCode).to.eq(201)

      // save the id of the user just created
      thisId = response.body.user['id']
    })
  });

  // click edit user
  it('user profile', () => {
    cy.visit('/users');
    cy.get(`[data-cy="show_${thisId}"]`).click().then(() => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', `/users/${thisId}/profile`);
    });
  });

  // edit the user profile
  it('user profile page', () => {
    cy.intercept('POST', `http://localhost:3001/api/v3/users/${thisId}/update_info`).as('updateprofile')

    cy.visit(`/users/${thisId}/profile`);
    cy.get('input[name="email"]')
      .type("test@test.com")
      .should("have.value", "test@test.com");

    cy.get('input[name="phone"]')
      .type("8005551212")
      .should("have.value", "8005551212");

    cy.get("form").submit()
    cy.wait('@updateprofile').should(({ request, response }) => {
      expect(response.statusCode).to.eq(200)
    })
  });

  // edit preferences
  it('edit preferences', () => {
    cy.intercept('POST', `http://localhost:3001/api/v3/users/${thisId}/preferences`).as('preferences')

    cy.visit(`/users/${thisId}/profile`);

    cy.get(`[data-cy="preferences"]`).click().then(() => {
      // wait 1 sec, there should be a better way to do this
      cy.wait(1000)

      cy.get('input[name="lab_name"]')
        .type("my lab")
        .should("have.value", "my lab");

      // cy and material do not play well together.
      // clicking the element triggers the toggle twice, and removing the .click() does nothing
      // but at least it triggers the toggle.
      cy.get(`[data-cy=privatetoggle]`).click()

      cy.get("form").submit()
      cy.wait('@preferences').should(({ request, response }) => {
        expect(response.statusCode).to.eq(200)
      })
    });
  });

  // click lab agreement
  it('lab agreement', () => {
    cy.intercept('POST', `http://localhost:3001/api/v3/users/${thisId}/agreements/lab_agreement`).as('labagreement')

    cy.visit(`/users/${thisId}/profile`);
    cy.get(`[data-cy="lab_agreement"]`).click().then(() => {
      // wait 3 sec, there should be a better way to do this
      cy.wait(3000)

      cy.get(`[data-cy="agree"]`).click().then(() => {
        cy.wait('@labagreement').should(({ request, response }) => {
          expect(response.statusCode).to.eq(200)
        })
      });
    });
  });

  // click aquarium agreement
  it('aquarium agreement', () => {
    cy.intercept('POST', `http://localhost:3001/api/v3/users/${thisId}/agreements/aquarium_agreement`).as('aquariumagreement')

    cy.visit(`/users/${thisId}/profile`);
    cy.get(`[data-cy="aquarium_agreement"]`).click().then(() => {
      // wait 3 sec, there should be a better way to do this
      cy.wait(3000)

      cy.get(`[data-cy="agree"]`).click().then(() => {
        cy.wait('@aquariumagreement').should(({ request, response }) => {
          expect(response.statusCode).to.eq(200)
        })
      });
    });
  });

//  IMPORTANT: Delete the user manually <or> reset the test DB after each (you cannot delete a user in Aquarium)
});
