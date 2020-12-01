/// <reference types="cypress" />
import React from 'react';
import { mount, unmount } from 'cypress-react-unit-test';
import { FieldLabels, SampleTypeField } from '../../src/components/sampleTypes/SampleTypeFieldForm';

describe('FieldLabels', () => {
  afterEach(() => {
    unmount('@Fieldlabels');
  });

  it('renders fields form container', () => {
    mount(<FieldLabels />);

    cy.get('div[name="field_labels"]')
      .should('be.visible')
      .within(() => {
        cy.get('[cy-data="field_name_label_div"]')
          .should('be.visible')
          .contains('h4', 'Field Name');

        cy.get('[cy-data="field_type_label_div"]')
          .should('be.visible')
          .contains('h4', 'Type');

        cy.get('[cy-data="field_is_required_label_div"]')
          .should('be.visible')
          .contains('h4', 'Required');

        cy.get('[cy-data="field_is_array_label_div"]')
          .should('be.visible')
          .contains('h4', 'Array');

        cy.get('[cy-data="field_sample_options_label_div"]')
          .should('be.visible')
          .contains('h4', 'Sample Options (If type=‘sample‘)');

        cy.get('[cy-data="field_choices_label_div"]')
          .should('be.visible')
          .contains('h4', 'Choices');
      });
  });
});

describe('SampleTypeFieldForm', () => {
  const fieldType = {
    id: null,
    name: '',
    type: '',
    isRequired: false,
    isArray: false,
    choices: '',
  };

  afterEach(() => {
    unmount('@SampleTypeField');
  });

  it('has field inputs div', () => {
    mount(
      <SampleTypeField
        fieldType={fieldType}
        index={0}
        updateParentState={() => cy.spy().as('updateParentState')}
        handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
      />,
    );
    cy.get('div[name="field_inputs"]')
      .should('exist');
  });

  describe.only('Name Input', () => {
    context('field type is an empty string/blank', () => {
      it('has empty input', () => {
        mount(
          <SampleTypeField
            fieldType={fieldType}
            index={0}
            updateParentState={() => cy.spy().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
        cy.get('[cy-data="field_name_label_div"]')
          .find('input[name="field_name"]')
          .should('have.value', '');
      });
      it('accepts user input', () => {
        const testName = 'Ms. Boop';
        mount(
          <SampleTypeField
            fieldType={fieldType}
            index={0}
            updateParentState={() => cy.spy().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />
        );
        cy.get('input[name="field_name"]').should('have.value', '').then(() => {
          cy.get('input[name="field_name"]')
            .type(testName)
            .should('have.value', testName);
        });
      });
    });

    context('field type is NOT an empty string', () => {
      const testFieldType = fieldType;
      const testName = 'Ms. Boop';
      testFieldType.name = testName;

      it('has value in field name input', () => {
        mount(
          <SampleTypeField
            fieldType={testFieldType}
            index={0}
            updateParentState={() => cy.spy().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />
        );
        cy.get('input[name="field_name"]').should('have.value', testName);
      });

      it('accepts user input', () => {
        const newName = 'Mr. Boop';
        mount(
          <SampleTypeField
            fieldType={testFieldType}
            index={0}
            updateParentState={() => cy.spy().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />
        );
        cy.get('input[name="field_name"]').should('have.value', testName);
        cy.get('input[name="field_name"]').type(newName).should('have.value', newName);
      });
    });
  });

  describe('Type Input', () => {
    it('has field type header and type matches input prop', () => {
      mount(
        <SampleTypeField
          fieldType={fieldType}
          index={0}
          updateParentState={() => cy.spy().as('updateParentState')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );
      cy.get('[cy-data="field_form_container"]')
        .should('be.visible')
        .within(() => {
          cy.contains('h5', 'Type');
          cy.get('input[name="type"]').should('have.value', fieldType.type);
        });
    });

    it(' calls update state function on user select', () => {
      mount(
        <SampleTypeField
          fieldType={fieldType}
          index={0}
          updateParentState={cy.stub().returns((fieldType.type = 'number'))}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );

      cy.get('[cy-data="field_form_container"]').within(() => {
        cy.contains('h5', 'Field Name');
        cy.get('[cy-data="field_type_select"]')
          .within(() => {
            cy.get('input');
          })
          .click();
      });

      cy.get('ul').within(() => {
        cy.get('li[name="select_number"]').trigger('select');
      });
      cy.get('[cy-data="field_type_select"]').within(() => {
        cy.get('input').should('have.value', 'number');
      });
    });
  });

  describe('isRequired checkbox', () => {
    beforeEach(() => {
      mount(
        <SampleTypeField
          fieldType={fieldType}
          index={0}
          updateParentState={cy
            .stub()
            .returns((fieldType.isRequired = true))
            .as('updateParentState')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );
    });

    it('renders "Required" header', () => {
      cy.get('[cy-data="field_form_container"]')
        .should('be.visible')
        .within(() => {
          cy.contains('h5', 'Required');
        });
    });

    it('has boolean checkbox label', () => {
      cy.get('label').should(
        'include.text',
        fieldType.isRequired.toString(),
      );
    });

    it('accepts user input, and update label', () => {
      cy.get('[cy-data="field_is_required_checkbox"]')
        .check()
        .should('have.value', 'true');

      cy.get('label').should(
        'include.text',
        fieldType.isRequired.toString(),
      );
    });
  });

  describe('Array checkbox', () => {
    beforeEach(() => {
      mount(
        <SampleTypeField
          fieldType={fieldType}
          index={0}
          updateParentState={cy
            .stub()
            .returns((fieldType.isArray = true))
            .as('updateParentState')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );
    });

    it('renders "Array" header', () => {
      cy.get('[cy-data="field_form_container"]')
        .should('be.visible')
        .within(() => {
          cy.contains('h5', 'Array');
        });
    });

    it('has boolean checkbox label', () => {
      cy.get('label').should('include.text', fieldType.isArray.toString());
    });

    it('accepts user input, and update label', () => {
      cy.get('[cy-data="field_is_array_checkbox"]')
        .check()
        .should('have.value', 'true');

      cy.get('label').should('include.text', fieldType.isArray.toString());
    });
  });

  describe('samples', () => {
    const fieldTypes = fieldType;

    context('when no field type is  selected', () => {
      beforeEach(() => {
        fieldTypes.type = '';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('does not have add button', () => {
        cy.get('[cy-data="samples_div"]')
          .find('[cy-data="add_field_option_btn"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[cy-data="samples_div"]').contains('p', 'N/A').should('exist');
      });
    });

    context('when field type is "string"', () => {
      beforeEach(() => {
        fieldTypes.type = 'string';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('does not have add button', () => {
        cy.get('[cy-data="samples_div"]')
          .find('[cy-data="add_field_option_btn"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[cy-data="samples_div"]').contains('p', 'N/A').should('exist');
      });
    });

    context('when field type is "number"', () => {
      beforeEach(() => {
        fieldTypes.type = 'number';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('does not have add button', () => {
        cy.get('[cy-data="samples_div"]')
          .find('[cy-data="add_field_option_btn"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[cy-data="samples_div"]').contains('p', 'N/A').should('exist');
      });
    });

    context('when field type is "url"', () => {
      beforeEach(() => {
        fieldTypes.type = 'url';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('does not have add button, when field type is "url"', () => {
        cy.get('[cy-data="samples_div"]')
          .find('[cy-data="add_field_option_btn"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[cy-data="samples_div"]').contains('p', 'N/A').should('exist');
      });
    });

    context('when field type is "sample"', () => {
      beforeEach(() => {
        fieldTypes.type = 'sample';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('has add button', () => {
        cy.get('[cy-data="samples_div"]')
          .find('[cy-data="add_field_option_btn"]')
          .should('exist');
      });

      it('does not have "N/A"', () => {
        cy.get('[cy-data="samples_div"]')
          .contains('p', 'N/A')
          .should('not.exist');
      });
    });
  });

  describe('Choices', () => {
    const fieldTypes = fieldType;

    context('when no field type is selected', () => {
      beforeEach(() => {
        fieldTypes.type = '';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('does not have choices input', () => {
        cy.get('[cy-data="choices_input_div"]')
          .find('[cy-data="add_field_choices_input"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[cy-data="choices_input_div"]')
          .contains('p', 'N/A')
          .should('exist');
      });
    });

    context('when field type is "string"', () => {
      beforeEach(() => {
        fieldTypes.type = 'string';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('has chocies input', () => {
        cy.log(fieldTypes);
        cy.get('[cy-data="choices_input_div"]')
          .find('[cy-data="add_field_choices_input"]')
          .should('exist');
      });

      it('does not have "N/A"', () => {
        cy.get('[cy-data="choices_input_div"]')
          .contains('p', 'N/A')
          .should('not.exist');
      });

      it('accepts user input', () => {
        const testInput = 'a, b, c';
        cy.get('[cy-data="choices_input_div"]')
          .find('[cy-data="add_field_choices_input"]')
          .type(testInput, { force: true });
      });
    });

    context('when field type is "number"', () => {
      beforeEach(() => {
        fieldTypes.type = 'number';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('has chocies input', () => {
        cy.get('[cy-data="choices_input_div"]')
          .find('[cy-data="add_field_choices_input"]')
          .should('exist');
      });

      it('does not have "N/A"', () => {
        cy.get('[cy-data="choices_input_div"]')
          .contains('p', 'N/A')
          .should('not.exist');
      });

      it('accepts user input', () => {
        const testInput = '1, 2, 3';
        cy.get('[cy-data="choices_input_div"]')
          .find('[cy-data="add_field_choices_input"]')
          .type(testInput, { force: true });
      });
    });

    context('when field type is "url"', () => {
      beforeEach(() => {
        fieldTypes.type = 'url';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('does not have chocies input', () => {
        cy.get('[cy-data="choices_input_div"]')
          .find('[cy-data="add_field_choices_input"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[cy-data="choices_input_div"]')
          .contains('p', 'N/A')
          .should('exist');
      });
    });

    context('when field type is "sample"', () => {
      beforeEach(() => {
        fieldTypes.type = 'sample';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
          />,
        );
      });

      it('does not have choices input', () => {
        cy.get('[cy-data="choices_input_div"]')
          .find('[cy-data="add_field_choices_input"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[cy-data="choices_input_div"]')
          .contains('p', 'N/A')
          .should('exist');
      });
    });
  });
});
