/// <reference types="cypress" />
/* eslint-disable react/jsx-filename-extension */
import React from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import { mount, unmount } from 'cypress-react-unit-test';
// import { BrowserRouter as Router } from 'react-router-dom';
import SampleTypeField from '../../src/components/sampleTypes/SampleTypeFieldForm';

describe('SampleTypeFieldForm', () => {
  const testFieldType = {
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

  it('renders fields form container', () => {
    mount(
      <SampleTypeField
        fieldType={testFieldType}
        index={0}
        updateParentState={() => cy.spy().as('updateParentState')}
        handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
      />,
    );
    cy.get('[cy-data="field_form_container"]')
      .should('be.visible')
      .within(() => {
        cy.contains('h5', 'Type');
        cy.contains('h5', 'Required');
        cy.contains('h5', 'Array');
        cy.contains('h5', 'Sample Options (If type=‘sample‘)');
        cy.contains('h5', 'Choices');
      });
  });

  describe('Name Input', () => {
    it('has field name header and input with placeholder text when fieldType is empty string', () => {
      mount(
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={() => cy.spy().as('updateParentState')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );
      cy.get('[cy-data="field_form_container"]')
        .within(() => {
          cy.contains('h5', 'Field Name');
          cy.get('input[name="name"]')
            .should('have.attr', 'placeholder', 'Field name');
        });
    });

    it('has field name header and input with placeholder text when fieldType is not empty string', () => {
      const fieldType = testFieldType;
      const testName = 'Test Name';
      fieldType.name = testName;
      mount(
        <SampleTypeField
          fieldType={fieldType}
          index={0}
          updateParentState={() => cy.spy().as('updateParentState')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );
      cy.get('[cy-data="field_form_container"]')
        .within(() => {
          cy.contains('h5', 'Field Name');
          cy.get('input[name="name"]')
            .should('have.value', testName);
        });
    });

    it('accepts user input', () => {
      const testName = 'Test Name';
      mount(
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={() => cy.spy().as('updateParentState')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );
      cy.get('[cy-data="field_form_container"]')
        .within(() => {
          cy.get('input[name="name"]')
            .type(testName)
            .should('have.value', testName);
        });
    });
  });

  describe('Type Input', () => {
    it('has field type header and type matches input prop', () => {
      mount(
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={() => cy.spy().as('updateParentState')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );
      cy.get('[cy-data="field_form_container"]')
        .should('be.visible')
        .within(() => {
          cy.contains('h5', 'Type');
          cy.get('input[name="type"]')
            .should('have.value', testFieldType.type);
        });
    });

    it(' calls update state function on user select', () => {
      mount(
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={cy.stub().returns(testFieldType.type = 'number')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );

      cy.get('[cy-data="field_form_container"]')
        .within(() => {
          cy.contains('h5', 'Field Name');
          cy.get('[cy-data="field_type_select"]')
            .within(() => {
              cy.get('input');
            })
            .click();
        });

      cy.get('ul')
        .within(() => {
          cy.get('li[name="select_number"]')
            .trigger('select');
        });
      cy.get('[cy-data="field_type_select"]')
        .within(() => {
          cy.get('input')
            .should('have.value', 'number');
        });
    });
  });

  describe('isRequired checkbox', () => {
    beforeEach(() => {
      mount(
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={cy.stub()
            .returns(testFieldType.isRequired = true).as('updateParentState')}
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
      cy.get('label').should('include.text', testFieldType.isRequired.toString());
    });

    it('accepts user input, and update label', () => {
      cy.get('[cy-data="field_is_required_checkbox"]')
        .check()
        .should('have.value', 'true');

      cy.get('label').should('include.text', testFieldType.isRequired.toString());
    });
  });

  describe('Array checkbox', () => {
    beforeEach(() => {
      mount(
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={cy.stub()
            .returns(testFieldType.isArray = true).as('updateParentState')}
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
      cy.get('label').should('include.text', testFieldType.isArray.toString());
    });

    it('accepts user input, and update label', () => {
      cy.get('[cy-data="field_is_array_checkbox"]')
        .check()
        .should('have.value', 'true');

      cy.get('label').should('include.text', testFieldType.isArray.toString());
    });
  });

  describe('samples', () => {
    const fieldTypes = testFieldType;

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
        cy.get('[cy-data="samples_div"]')
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

      it('does not have add button', () => {
        cy.get('[cy-data="samples_div"]')
          .find('[cy-data="add_field_option_btn"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[cy-data="samples_div"]')
          .contains('p', 'N/A')
          .should('exist');
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
        cy.get('[cy-data="samples_div"]')
          .contains('p', 'N/A')
          .should('exist');
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
        cy.get('[cy-data="samples_div"]')
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

  describe.only('Choices', () => {
    const fieldTypes = testFieldType;

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
