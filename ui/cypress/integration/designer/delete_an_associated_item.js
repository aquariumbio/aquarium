
describe('Delete and Associated Item', function() {

  it('Remembers deleted items', function() {

    // Login
    cy.login()
    cy.designer()

    cy.window().then(win => {
      var sid, oid;
      let AQ = win.AQ;
      return AQ.Sample
        .find_by_name("First Fragment")
        .then(sample => sid = sample.id)
        .then(() => AQ.ObjectType.find_by_name("Fragment Stock"))
        .then(ot => oid = ot.id)
        .then(() => AQ.get("/items/make/" + sid + "/" + oid ))
    });

    // Build a plan, choose the second item for an input, and save it
    cy.design_with("Basic Cloning")
      .add_operation('Assemble Plasmid')
      .choose_operation_box('Assemble Plasmid')
      .associate_sample_to_output('Assembled Plasmid', 'First Plasmid')
      .associate_sample_to_input('Fragment', 'First Fragment')
      .choose_second_item()
      .save_as("My Test Plan")

    // Delete the item
    cy.choose_operation_box('Assemble Plasmid')
      .choose_input('Assemble Plasmid', 0)
      .open_second_item()
      .get(`[data-item-popup-action=delete]`).click()
      .get(`[data-item-popup-action=close]`).click()

    // Launch the plan and then check it the item is still chosen
    cy.launch("My First Budget")
      .wait(1000)

    cy.choose_operation_box('Assemble Plasmid')
      .choose_input('Assemble Plasmid', 0)
      .get_first_item_checkbox()
      .should('not.have.attr', 'checked')

    });

  });
