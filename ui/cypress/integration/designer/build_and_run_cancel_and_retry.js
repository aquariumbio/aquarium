
describe('Build plan with retry', function() {

  it('Builds a plan, errors an operation, and retries it', function() {

    // Login
    cy.login()

    // Build and launch a plan 
    cy.designer()
      .design_with("Basic Cloning")
      .add_operation('Make PCR Fragment')
      .choose_output('Make PCR Fragment',0)
      .choose_successor('Run Gel')
      .choose_input('Run Gel',1)
      .choose_predecessor('Pour Gel')
      .choose_input('Make PCR Fragment',0)
      .choose_predecessor('Rehydrate Primer')
      .choose_input('Rehydrate Primer',0)
      .choose_predecessor('Order Primer')
      .choose_operation_box('Run Gel')
      .associate_sample_to_output('Fragment', 'Second Fragment')
      .define_parameter('Order Primer', 'Urgent?', 'yes')   
      .save_as("My Test Plan")
      .launch("My First Budget")
     
    // Check operation statuses
    cy.operation_status_is('Order Primer',      'pending')
      .operation_status_is('Rehydrate Primer',  'waiting')
      .operation_status_is('Make PCR Fragment', 'waiting')
      .operation_status_is('Pour Gel',          'primed' )
      .operation_status_is('Run Gel',           'waiting')    

    // run the plan (up to make pcr)
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

    // Check operation statuses
    cy.designer()   
      .load_first_plan_in_folder('unsorted')
      .operation_status_is('Order Primer',      'done')
      .operation_status_is('Rehydrate Primer',  'done')
      .operation_status_is('Make PCR Fragment', 'done')

    // Set make pcr to errored
    cy.set_operation_status('Make PCR Fragment', 'pending')
      .set_operation_status('Make PCR Fragment', 'error')

    // check that output of make pcr is here
    cy.choose_output('Make PCR Fragment',0)
      .get("[data-operation-viewer-field-value-name='Fragment']" + 
           "[data-operation-viewer-field-value-role=output]")
      .within(() => {
        cy.get("[data-open-item-popup]").last()
          .click()
          .wait(1000)
      })

    
    cy.get("[data-popup-title-item-id]").then(el => {
      let output_item_id = el.data("popup-title-item-id")

      // check location validity of item in popup
      cy.get(`[data-item-id=${output_item_id}][data-item-popup-action=delete]`).click()
        .get(`[data-item-id=${output_item_id}][data-item-popup-action=restore]`).click()          
        .get(`[data-item-id=${output_item_id}][data-item-popup-input=location]`).then(input => {
          expect(input.val()).to.eq("Bench")
        })

      //close popup
      cy.get(`[data-item-id=${output_item_id}][data-item-popup-action=close]`)
        .click()
    
      // retry the errored make pcr operation
      cy.manager()
        .manager_category("Basic Cloning")
        .get(".md-thumb").click()
        .wait(1000)
        .manager_operation_list("Make PCR Fragment", "error")
        .manager_check_first_operation()
        .manager_action('retry')
        .wait(1000)

      // Check operation statuses
      cy.designer()   
        .load_first_plan_in_folder('unsorted')
        .operation_status_is('Order Primer',      'done')
        .operation_status_is('Rehydrate Primer',  'done')
        .operation_status_is('Make PCR Fragment', 'pending')

      // ensure output item is cleared for retried operation
      cy.choose_output('Make PCR Fragment',0)
        .get("[data-operation-viewer-field-value-name='Fragment']" + 
             "[data-operation-viewer-field-value-role=output]")
        .within(() => {
          cy.get("[data-open-item-popup]").should('not.exist')
        }) 

      // ensure previous output item for retried operation has now been marked as deleted
      cy.samples()
        .samples_search_item(output_item_id)
        .get(`[data-item-id=${output_item_id}][data-item-popup-action=restore]`)

    })
    
  });

})
