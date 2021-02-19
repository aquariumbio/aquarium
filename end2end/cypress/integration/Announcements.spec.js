describe('/announcements', () => {
  beforeEach(() => {
    cy.login();
  });

  it('has place holder header', () => {
    cy.visit('/announcements');
    cy.contains('h1', 'Announcements');
  });
});
