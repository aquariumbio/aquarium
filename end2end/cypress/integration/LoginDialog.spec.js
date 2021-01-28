describe('/login', () => {
  beforeEach(() => {
    window.localStorage.clear();
    cy.visit('/login');
  });

  it('greets with powered by aquarium', () => {
    cy.contains('h6', 'Powered by Aquarium');
  });

  it('requires username', () => {
    cy.get('form').contains('SIGN IN').click();
    cy.get('p').should('contain', 'Invalid login/password combination');
  });

  it('requires password, enter submits form', () => {
    cy.get('[data-test=username]').type('fakeuser{enter}');
    cy.get('p').should('contain', 'Invalid login/password combination');
  });

  it('requires valid username and password', () => {
    cy.get('[data-test=username]').type('marikotest ');
    cy.get('[data-test=password]').type('invalid');
    cy.get('form').contains('SIGN IN').click().then(() => {
      cy.get('p').should('contain', 'Invalid login/password combination');
    });
  });

  it('navigates to / on successful login', () => {
    cy.window()
      .then((win) => {
        expect(win.localStorage.token).to.be.undefined;
      });

    cy.get('[data-test=username]').type('marikotest ');
    cy.get('[data-test=password]').type('aquarium');
    cy.get('form').contains('SIGN IN').click();
    cy.url().should('eq', `${Cypress.env('baseUrl')}/`);

    let token;

    cy.window()
      .then((win) => {
        token = win.localStorage.token;
      })
      .then(() => {
        expect(token).to.exist;
      });
  });

  // TODO: test localStorage for token after login
});
