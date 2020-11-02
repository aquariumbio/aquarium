/* eslint-disable jest/valid-expect */
describe('/login', function () {
  beforeEach(() => {
    cy.clearLocalStorage()
    cy.visit('/login')
  })

  it('greets with powered by aquarium', () => {
      cy.contains('h6', 'Powered by Aquarium')
  })

  it('requires username', () => {
    cy.get('form').contains('SIGN IN').click()
    cy.get('p').should('contain', 'Invalid login/password combination')
  })

  it('requires password, enter submits form', () => {
    cy.get('[data-test=username]').type('maggie{enter}')
    cy.get('p').should('contain', 'Invalid login/password combination')
  })

  it('requires valid username and password', () => {
    cy.get('[data-test=username]').type('marikoa')
    cy.get('[data-test=password]').type('invalid')
    cy.get('form').contains('SIGN IN').click()
    cy.get('p').should('contain', 'Invalid login/password combination')
  })

  it('navigates to / on successful login', () => {
    cy.window()
    .then((win) => {
      // eslint-disable-next-line no-unused-expressions
      expect(win.localStorage.token).to.be.undefined
    })

    cy.get('[data-test=username]').type('marikoa')
    cy.get('[data-test=password]').type('MtXzwmLYTDq5Gucr')
    cy.get('form').contains('SIGN IN').click()
    cy.url().should('eq', 'http://localhost:3002/aquarium/v3/')

        
    let token

    cy.window()
      .then((win) => {
        token = win.localStorage.token
      })
      .then(() => {
        // eslint-disable-next-line no-unused-expressions
        expect(token).to.exist
      })
  })

  // TODO: test localstorage for token after login
})