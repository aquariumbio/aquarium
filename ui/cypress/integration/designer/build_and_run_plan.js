
describe('Build plan', function() {

  it('Builds a plan and saves it', function() {

    // Set up routes
    cy.server()
      .route('POST', '/plans.json*').as('savePlan')
      .route('POST', '/json*').as('getBudget')  
      .route('GET', '/plans/folders*').as('getFolders') 
      .route('GET', '/krill/debug/*').as('debugJob') 

    // Go to designer page
    cy.login()
      .designer()

    // Choose Cloning
    cy.get('[data-sidebar=design]').click()
      .get("[data-design='Operation Types']").click()
      .get("[data-operation-type-category='Basic Cloning']").click()

    // PCR
    cy.get("[data-add-operation-type='Make PCR Fragment']").click()
      .get("#dismiss-messages").click()
      .get("[data-output-of='Make PCR Fragment'][data-output-number=0]").click()

    // Run Gel
    cy.get("[data-successor='Run Gel']").click()
      .get("[data-input-of='Run Gel'][data-input-number=1]").click()

    // Pour Gel
    cy.get("[data-predecessor='Pour Gel']").click()    
      .get("[data-input-of='Make PCR Fragment'][data-input-number=0]").click()

    // Rehydrate Primer
    cy.get("[data-predecessor='Rehydrate Primer']").click()       
      .get("[data-input-of='Rehydrate Primer'][data-input-number=0]").click()

    // Order Primer
    cy.get("[data-predecessor='Order Primer']").click()
      .get("[data-operation-box='Run Gel']").click()

    // Fill in samples and parameters
    cy.get('[data-input-type=output][data-input-name=Fragment]')
      .type("Sec")

    cy.contains('Second Fragment').click()
      .wait(1000)
      .get("[data-operation-box='Order Primer']").click()
      .get("[data-parameter='Urgent?']").type("yes")
      .get("#plan-editor-container").scrollTo(0,0)

    // Give the plan a name, save it, and make sure it has an id
    cy.get("#plan-title-input").clear().type("My Test Plan")
      .get("[data-action=Save]").click()
      .wait(['@savePlan', '@getBudget', '@getFolders']).then((xhrs) => {
      const id = xhrs[0].response.body.id
      cy.wrap(id).should('be.above', 0)
    })

    // Launch the plan
    cy.get("[data-sidebar=launch]").click()
      .get(`[data-invalid-plan]`).should('not.be.visible')
      .get("[data-sidebar-budget-checkbox='My First Budget']").click()
      .get('[data-sidebar-action=submit]').click()
      .operation_status_is('Order Primer',      'pending')
      .operation_status_is('Rehydrate Primer',  'waiting')
      .operation_status_is('Make PCR Fragment', 'waiting')
      .operation_status_is('Pour Gel',          'primed' )
      .operation_status_is('Run Gel',           'waiting')    

    // run the plan
    cy.manager()
      .manager_category("Basic Cloning")

      .manager_operation_list("Order Primer", "pending")
      .manager_check_last_operation()
      .manager_action('schedule')
      .manager_job_action('debug')
      .wait('@debugJob')      

      .manager_operation_list("Rehydrate Primer", "pending")
      .manager_check_last_operation()
      .manager_action('schedule')
      .manager_job_action('debug')
      .wait('@debugJob')      

      .manager_operation_list("Make PCR Fragment", "pending")
      .manager_check_last_operation()
      .manager_action('schedule')
      .manager_job_action('debug')
      .wait('@debugJob')

      .manager_operation_list("Run Gel", "pending")
      .manager_check_last_operation()
      .manager_action('schedule')
      .wait(1000) // todo: replace with an alias
      
      .manager_operation_list("Pour Gel", "scheduled")
      .manager_job_action('debug')
      .wait('@debugJob')      

      .manager_operation_list("Run Gel", "scheduled")
      .manager_job_action('debug')  
      .wait('@debugJob')       

    cy.designer()   
      .get('[data-sidebar=plans]').click()
      .get('[data-plan-folder=unsorted]').click()
      .get('[data-load-plan]').first().click()
      .operation_status_is('Order Primer',      'done')
      .operation_status_is('Rehydrate Primer',  'done')
      .operation_status_is('Make PCR Fragment', 'done')
      .operation_status_is('Pour Gel',          'done')
      .operation_status_is('Run Gel',           'done')        
 
  });

})
