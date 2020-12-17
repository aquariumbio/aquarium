/// <reference types="cypress" />
import React from 'react';
import { mount, unmount } from 'cypress-react-unit-test';
import { FieldLabels, SampleTypeField } from '../../src/components/sampleTypes/SampleTypeFieldForm';

describe('FieldLabels', () => {
  it('renders field labels form container', () => {
    mount(<FieldLabels />);

    cy.get('[data-cy="field-labels"]')
      .should('be.visible')
      .within(() => {
        cy.get('[data-cy="field-name-label-div"]')
          .should('be.visible')
          .contains('h4', 'Field Name');

        cy.get('[data-cy="field-type-label-div"]')
          .should('be.visible')
          .contains('h4', 'Type');

        cy.get('[data-cy="field-is-required-label-div"]')
          .should('be.visible')
          .contains('h4', 'Required');

        cy.get('[data-cy="field-is-array-label-div"]')
          .should('be.visible')
          .contains('h4', 'Array');

        cy.get('[data-cy="field-sample-options-label-div"]')
          .should('be.visible')
          .contains('h4', 'Sample Options (If type=‘sample‘)');

        cy.get('[data-cy="field-choices-label-div"]')
          .should('be.visible')
          .contains('h4', 'Choices');
      });
  });
});

describe('SampleTypeFieldForm', () => {
  const fieldType = {
    id: null,
    name: '',
    ftype: '',
    required: false,
    array: false,
    choices: '',
  };

  afterEach(() => {
    unmount('@SampleTypeField');
  });

  it('has field inputs container', () => {
    const testFieldType = {
      id: null,
      name: '',
      ftype: '',
      required: false,
      array: false,
      choices: '',
    };

    mount(
      <SampleTypeField
        fieldType={testFieldType}
        index={0}
        updateParentState={cy.spy().as('updateParentState')}
        handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
      />,
    );
    cy.get('[data-cy="field-inputs"]').should('exist');
  });

  describe('Name Input', () => {
    context('field type is an empty string/blank', () => {
      it('has empty input', () => {
        const testFieldType = {
          id: null,
          name: '',
          ftype: '',
          required: false,
          array: false,
          choices: '',
        };
        mount(
          <SampleTypeField
            fieldType={testFieldType}
            index={0}
            updateParentState={cy.spy().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
        cy.get('[data-cy="field-name-input"]').should('have.value', '');
      });

      it('accepts user input', () => {
        const testFieldType = {
          id: null,
          name: '',
          ftype: '',
          required: false,
          array: false,
          choices: '',
          allowableFieldTypes: [],
        };

        const testName = 'Ms. Boop';
        mount(
          <SampleTypeField
            fieldType={testFieldType}
            index={0}
            updateParentState={cy.spy().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );

        cy.get('[data-cy="field-name-input"]')
          .type(testName);

        //  Get the spy for assertion
        cy.get('@updateParentState').should('have.callCount', testName.length);
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
            updateParentState={cy.spy().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
        cy.get('[data-cy="field-name-input"]').should('have.value', testName);
      });

      it('accepts user input', () => {
        const newName = 'Mr. Boop';
        mount(
          <SampleTypeField
            fieldType={testFieldType}
            index={0}
            updateParentState={cy.spy().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
        cy.get('[data-cy="field-name-input"]')
          .type(newName);
        cy.get('@updateParentState').should('have.callCount', newName.length);
      });
    });
  });

  describe('Type Input', () => {
    it('has field type matches input prop', () => {
      const testFieldType = fieldType;
      mount(
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={cy.spy().as('updateParentState')}
          handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
        />
      );

      cy.get('[data-cy="ftype-input"]').should('have.value', testFieldType.ftype);
    });

    it(' calls update state function on user select', () => {
      mount(
        <SampleTypeField
          fieldType={fieldType}
          index={0}
          updateParentState={cy.spy().as('updateParentState')}
          handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
        />
      );

      // Open then select menu
      cy.get('[data-cy="ftype-select"]')
        .click();

      // Select an option
      cy.get('ul').within(() => {
        cy.get('li[name="select-number"]').click();
      });

      // Selection should trigger update
      cy.get('@updateParentState').should('have.been.calledOnce');
    });
  });

  describe('required checkbox', () => {
    beforeEach(() => {
      mount(
        <SampleTypeField
          fieldType={fieldType}
          index={0}
          updateParentState={cy.spy().as('updateParentState')}
          handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
        />,
      );
    });

    it('accepts user input', () => {
      // Get and check required checkbox
      cy.get('[data-cy="field-required-checkbox"]').check();

      // Check should trigger update
      cy.get('@updateParentState').should('have.been.calledOnce');
    });
  });

  describe('Array checkbox', () => {
    beforeEach(() => {
      mount(
        <SampleTypeField
          fieldType={fieldType}
          index={0}
          updateParentState={cy.spy().as('updateParentState')}
          handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
        />
      );
    });

    it('accepts user input', () => {
      // Get and check required checkbox
      cy.get('[data-cy="array-checkbox"]').check();

      // Check should trigger update
      cy.get('@updateParentState').should('have.been.calledOnce');
    });
  });

  describe('samples', () => {
    const fieldTypes = fieldType;

    context('when no field type is  selected', () => {
      beforeEach(() => {
        fieldTypes.ftype = '';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('does not have add button', () => {
        cy.get('[data-cy="samples-div"]')
          .find('[data-cy="add-field-option-btn"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[data-cy="samples-div"]').contains('p', 'N/A').should('exist');
      });
    });

    context('when field type is "string"', () => {
      beforeEach(() => {
        fieldTypes.ftype = 'string';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('does not have add button', () => {
        cy.get('[data-cy="samples-div"]')
          .find('[data-cy="add-field-option-btn"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[data-cy="samples-div"]').contains('p', 'N/A').should('exist');
      });
    });

    context('when field type is "number"', () => {
      beforeEach(() => {
        fieldTypes.ftype = 'number';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('does not have add button', () => {
        cy.get('[data-cy="samples-div"]')
          .find('[data-cy="add-field-option-btn"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[data-cy="samples-div"]').contains('p', 'N/A').should('exist');
      });
    });

    context('when field type is "url"', () => {
      beforeEach(() => {
        fieldTypes.ftype = 'url';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('does not have add button, when field type is "url"', () => {
        cy.get('[data-cy="samples-div"]')
          .find('[data-cy="add-field-option-btn"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[data-cy="samples-div"]').contains('p', 'N/A').should('exist');
      });
    });

    context('when field type is "sample"', () => {
      beforeEach(() => {
        fieldTypes.ftype = 'sample';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('has add button', () => {
        cy.get('[data-cy="samples-div"]');
        cy.get('[data-cy="add-field-option-btn"]');
      });

      it('does not have "N/A"', () => {
        cy.get('[data-cy="samples-div"]')
          .contains('p', 'N/A')
          .should('not.exist');
      });
    });
  });

  describe('Choices', () => {
    const fieldTypes = fieldType;

    context('when no field type is selected', () => {
      beforeEach(() => {
        fieldTypes.ftype = '';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('does not have choices input', () => {
        cy.get('[data-cy="choices-input-div"]')
          .find('[data-cy="add-field-choices-input"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[data-cy="choices-input-div"]')
          .contains('p', 'N/A')
          .should('exist');
      });
    });

    context('when field type is "string"', () => {
      beforeEach(() => {
        fieldTypes.ftype = 'string';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.spy().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('has chocies input', () => {
        cy.log(fieldTypes);
        cy.get('[data-cy="choices-input-div"]')
          .find('[data-cy="add-field-choices-input"]')
          .should('exist');
      });

      it('does not have "N/A"', () => {
        cy.get('[data-cy="choices-input-div"]')
          .contains('p', 'N/A')
          .should('not.exist');
      });

      it('accepts user input', () => {
        const testInput = 'a, b, c';
        // Get textfield then type input
        cy.get('[data-cy="add-field-choices-input"]')
          .type(testInput);

        // Check that updateParentState was triggered by type input
        cy.get('@updateParentState').should('have.callCount', testInput.length);
      });
    });

    context('when field type is "number"', () => {
      beforeEach(() => {
        fieldTypes.ftype = 'number';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.spy().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('has chocies input', () => {
        cy.get('[data-cy="choices-input-div"]')
          .find('[data-cy="add-field-choices-input"]')
          .should('exist');
      });

      it('does not have "N/A"', () => {
        cy.get('[data-cy="choices-input-div"]')
          .contains('p', 'N/A')
          .should('not.exist');
      });

      it('accepts user input', () => {
        const testInput = '1, 2, 3';

        // Get textfield then type input
        cy.get('[data-cy="add-field-choices-input"]').type(testInput);

        // Check that updateParentState was triggered by type input
        cy.get('@updateParentState').should('have.callCount', testInput.length);
      });
    });

    context('when field type is "url"', () => {
      beforeEach(() => {
        fieldTypes.ftype = 'url';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('does not have chocies input', () => {
        cy.get('[data-cy="choices-input-div"]')
          .find('[data-cy="add-field-choices-input"]')
          .should('not.exist');
      });

      it('has "N/A" as choices placeholder', () => {
        cy.get('[data-cy="choices-input-div"]')
          .contains('p', 'N/A')
          .should('exist');
      });
    });

    context('when field type is "sample"', () => {
      beforeEach(() => {
        fieldTypes.ftype = 'sample';
        mount(
          <SampleTypeField
            fieldType={fieldTypes}
            index={0}
            updateParentState={cy.stub().as('updateParentState')}
            handleRemoveFieldClick={cy.spy().as('handleRemoveFieldClick')}
          />
        );
      });

      it('does not have choices input', () => {
        cy.get('[data-cy="choices-input-div"]')
          .find('[data-cy="add-field-choices-input"]')
          .should('not.exist');
      });

      it('has "N/A"', () => {
        cy.get('[data-cy="choices-input-div"]')
          .contains('p', 'N/A')
          .should('exist');
      });
    });
  });
});
