describe('Samples', function() {

  it('Gets a properly formed sample names object', function() {

    cy.login();  
    cy.designer();

    cy.window().then(win => {

      let AQ = win.AQ;

      return AQ.get_sample_names().then(() => {

        cy.wrap(AQ).its('sample_names').should("not.equal", null);
        cy.wrap(AQ).its('sample_names').should("be.a",'object');

        for ( var type in AQ.sample_names ) {
          cy.wrap(AQ.sample_names).its(type).should("be.a","array")
          AQ.sample_names[type].forEach(sid => {
            cy.wrap(sid).should("be.a","string")
            cy.wrap(sid.split(": ").length).should("equal",2)
          });
        }

      })

    });

  });

});