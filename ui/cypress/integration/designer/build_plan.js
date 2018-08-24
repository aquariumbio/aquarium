
describe('Build plan', function() {

  it('Builds a plan and saves it', function() {

    // Set up routes
    cy.server()
    cy.route('POST', '/plans.json*').as('savePlan')
    cy.route('POST', '/json*').as('getBudget')  
    cy.route('GET', '/plans/folders*').as('getFolders') 

    // Go to designer page
    cy.login();  
    cy.designer();

    // Choose Cloning
    cy.get('[data-sidebar=design]').click()
    cy.get("[data-design='Operation Types']").click()
    cy.get("[data-operation-type-category='Basic Cloning']").click()

    // PCR
    cy.get("[data-add-operation-type='Make PCR Fragment']").click()
    cy.get("#dismiss-messages").click()

    cy.get("[data-output-of='Make PCR Fragment'][data-output-number=0]").click()

    // Run Gel
    cy.get("[data-successor='Run Gel']").click()
    cy.get("[data-input-of='Run Gel'][data-input-number=1]").click()

    // Pour Gel
    cy.get("[data-predecessor='Pour Gel']").click()    
    cy.get("[data-input-of='Make PCR Fragment'][data-input-number=0]").click()

    // Rehydrate Primer
    cy.get("[data-predecessor='Rehydrate Primer']").click()       
    cy.get("[data-input-of='Rehydrate Primer'][data-input-number=0]").click()

    // Order Primer
    cy.get("[data-predecessor='Order Primer']").click()
    cy.get("[data-operation-box='Run Gel']").click()

    // Fill in samples and parameters
    cy.get('[data-input-type=output][data-input-name=Fragment]').type("Sec")
    cy.contains('Second Fragment').click()
    cy.wait(1000)
    cy.get("[data-operation-box='Order Primer']").click()
    cy.get("[data-parameter='Urgent?']").type("yes");

    cy.get("#plan-editor-container").scrollTo(0,0)

    // Give the plan a name, save it, and make sure it has an id
    cy.get("#plan-title-input").clear().type("My Test Plan")
    cy.get("[data-action=Save]").click()
    cy.wait(['@savePlan', '@getBudget', '@getFolders']).then((xhrs) => {
      cy.wrap(xhrs[0].response.body.id).should('be.above', 0)
    })

    cy.get("[data-sidebar=launch]").click()

  });

})
