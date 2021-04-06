var newUserId
var newUserLogin

describe('/users', () => {
  beforeEach(() => {
    cy.login();
  });

  afterEach(() => {
    cy.logout();
  });

  // user page
  it('user page', () => {
    cy.visit('/users');
    cy.contains('h1', 'All');
    cy.get('[data-cy="new_user_btn"]').click().then(() => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', '/users/new');
    });
  });

  // new user page
  it('new user page', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/users/create?*`).as('newuser')

    cy.visit('/users/new');
    cy.contains('h1', 'New User');
    cy.get('input[name="name"]')
      .type("name")
      .should("have.value", "name");

    newUserLogin = "login-"+Math.floor((Math.random() * 1000000) + 1);
    cy.get('input[name="login"]')
      .type(`${newUserLogin}`)
      .should("have.value", `${newUserLogin}`);

    cy.get('input[name="password"]')
      .type("aquarium123")
      .should("have.value", "aquarium123");

    cy.get("form").submit()
    cy.wait('@newuser').should(({ request, response }) => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', `/users`);
      // save the id of the user just created
      newUserId = response.body.user['id']
    })
  });

  // click edit user
  it('user profile', () => {
    cy.visit('/users');
    cy.get(`[data-cy="show_${newUserId}"]`).click().then(() => {
      // wait for up to 3 seconds for the page to load
      cy.location('pathname', {timeout: 3000}).should('eq', `/users/${newUserId}/profile`);
    });
  });

  // edit the user profile
  it('user profile page', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/users/${newUserId}/update_info?*`).as('updateprofile')

    cy.visit(`/users/${newUserId}/profile`);

    // type email
    cy.get('input[name="email"]')
      .type("test@test.com")
      .should("have.value", "test@test.com");

    // type phone
    cy.get('input[name="phone"]')
      .type("8005551212")
      .should("have.value", "8005551212");


    // hit reset - value should reset
    cy.get(`[data-cy=reset]`).click()
    cy.get('input[name="email"]')
      .should("have.value", "");
    cy.get('input[name="phone"]')
      .should("have.value", "");

    // type email
    cy.get('input[name="email"]')
      .type("test@test.com")
      .should("have.value", "test@test.com");

    // type phone
    cy.get('input[name="phone"]')
      .type("8005551212")
      .should("have.value", "8005551212");

    cy.get("form").submit()
    cy.wait('@updateprofile').should(({ request, response }) => {
      // values should have changed
      cy.get('input[name="email"]')
        .should("have.value", "test@test.com");
      cy.get('input[name="phone"]')
        .should("have.value", "8005551212");
    })
  });

  // edit preferences
  it('edit preferences', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/users/${newUserId}/preferences?*`).as('preferences')

    cy.visit(`/users/${newUserId}/profile`);
    // wait 1 sec, there should be a better way to do this
    cy.wait(1000)
    cy.get(`[data-cy="preferences"]`).click().then(() => {
      // type lab name
      cy.get('input[name="lab_name"]')
        .type("my lab")
        .should("have.value", "my lab");

      // hit reset - value should reset
      cy.get(`[data-cy=reset]`).click()
      cy.get('input[name="lab_name"]')
        .should("have.value", "");

      // type lab name
      cy.get('input[name="lab_name"]')
        .type("my lab")
        .should("have.value", "my lab");
      // click toggle
      cy.get(`[data-cy=privatetoggle]`).click()

      cy.get("form").submit()
      cy.wait('@preferences').should(({ request, response }) => {
        // values should have changed
        cy.get('input[name="lab_name"]')
          .should("have.value", "my lab");
      })
    });
  });

  // change password (and change back)
  it('change password', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/users/${newUserId}/update_password?*`).as('password')

    cy.visit(`/users/${newUserId}/profile`);
    // wait 1 sec, there should be a better way to do this
    cy.wait(1000)
    cy.get(`[data-cy="password"]`).click().then(() => {
      // type new password
      cy.get('input[name="password1"]')
        .type("password123")
        .should("have.value", "password123");

      // type new password
      cy.get('input[name="password2"]')
        .type("password123")
        .should("have.value", "password123");

      cy.get(`[data-cy="save-password"]`).click().then(() => {
        cy.wait('@password').should(({ request, response }) => {
          // logout and log back in with new password
          cy.logout();

          // log in as the new user with the new password
          cy.visit('/login');
          cy.get('[data-test=username]').type(`${newUserLogin}`);
          cy.get('[data-test=password]').type('password123');
          cy.get('form').contains('SIGN IN').click();

          // should be logged in
          cy.location('pathname', {timeout: 3000}).should('eq', '/');
        });
      });
    });

  });

  // click lab agreement
  it('lab agreement', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/users/${newUserId}/agreements/lab_agreement?*`).as('labagreement')

    cy.visit(`/users/${newUserId}/profile`);
    // wait 1 sec, there should be a better way to do this
    cy.wait(1000)
    cy.get(`[data-cy="lab_agreement"]`).click().then(() => {
      cy.get(`[data-cy="agree"]`).click().then(() => {
        cy.wait('@labagreement').should(({ request, response }) => {
          // check that agreement button disappears
          cy.get(`[data-cy="agree"]`).should('not.exist');

          // check that agreed on appears
          cy.contains('agreed on')
        })
      });
    });
  });

  // click aquarium agreement
  it('aquarium agreement', () => {
    cy.intercept('POST', `${Cypress.env('API_URL')}/api/v3/users/${newUserId}/agreements/aquarium_agreement?*`).as('aquariumagreement')

    cy.visit(`/users/${newUserId}/profile`)
    // wait 1 sec, there should be a better way to do this
    cy.wait(1000)
    cy.get(`[data-cy="aquarium_agreement"]`).click().then(() => {
      cy.get(`[data-cy="agree"]`).click().then(() => {
        cy.wait('@aquariumagreement').should(({ request, response }) => {
          // check that agreement button disappears
          cy.get(`[data-cy="agree"]`).should('not.exist');

          // check that agreed on appears
          cy.contains('agreed on')
        })
      });
    });
  });

});
