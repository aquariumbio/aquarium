/* eslint-disable jest/valid-expect */
describe('/logout', function () {
  beforeEach(() => {
    cy.login()
  })

  it('has place holder header', () => {
    cy.visit('/logout')
    
    let token

    cy.window()
      .then((win) => {
        token = win.localStorage.token
      })
      .then(() => {
        // eslint-disable-next-line no-unused-expressions
        expect(token).to.exist
      })
    cy.contains('button', 'SIGN OUT').click()
    cy.url().should('contain', '/aquarium/v3/login')
    cy.window()
      .then((win) => {
        // eslint-disable-next-line no-unused-expressions
        expect(win.localStorage.token).to.be.undefined
      })
  })

})