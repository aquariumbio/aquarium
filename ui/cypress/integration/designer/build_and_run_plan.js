
describe('Build plan', function() {

  it('Builds a plan and runs it', function() {

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
      .wait(1000) // TODO: replace with an alias

      .manager_operation_list("Pour Gel", "scheduled")
      .manager_job_action('debug')
      .wait('@debugJob')  

      .manager_operation_list("Run Gel", "scheduled")
      .manager_job_action('debug') 
      .wait('@debugJob')  

    cy.designer()   
      .load_first_plan_in_folder('unsorted')
      .operation_status_is('Order Primer',      'done')
      .operation_status_is('Rehydrate Primer',  'done')
      .operation_status_is('Make PCR Fragment', 'done')
      .operation_status_is('Pour Gel',          'done')
      .operation_status_is('Run Gel',           'done')   

    cy.choose_output('Rehydrate Primer',0)
      .get("[data-operation-viewer-field-value-name='Primer Aliquot']" + 
           "[data-operation-viewer-field-value-role=output]")
      .within(() => {
        cy.get("[data-open-item-popup]")
          .click()
          .get("[data-popup-title-item-id]").then(el => {
            const id = el.data("popup-title-item-id")
            cy.test_item_popup(id)
          })
      })
 
  });

})
