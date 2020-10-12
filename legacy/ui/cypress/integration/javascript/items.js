describe('Items', function() {

  it('Makes item queries', function() {

    cy.login();  
    cy.designer();

    cy.window().then(win => {

      let AQ = win.AQ;

      return Promise.all([

        AQ.Item.find(14).then(item => {
          cy.wrap(item).its('id').should('equal',14);
        }),

        AQ.Item.find(123456789).then(item => {
          cy.wrap(0).should("equal",1)
        }).catch(e => { 
          return;
        }),

        AQ.Item.where("id > 0", {}, { limit: 4 }).then(items => {
          cy.wrap(items.length).should('equal',4)
        })

      ])

    });

  });

});