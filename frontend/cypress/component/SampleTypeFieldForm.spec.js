/// <reference types="cypress" />
/* eslint-disable react/jsx-filename-extension */
import React from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import { mount } from 'cypress-react-unit-test';
// import { BrowserRouter as Router } from 'react-router-dom';
import SampleTypeFieldForm from '../../src/components/sampleTypes/SampleTypeFieldForm';

describe('SampleTypeFieldForm', () => {
  const testFieldType = {
    id: null,
    name: '',
    type: 'string',
    isRequired: false,
    isArray: false,
    choices: '',
  };

  it('renders fields form container', () => {
    const handleFieldInputChange = cy.stub();
    const handleRemoveFieldClick = cy.stub();
    mount(
      <SampleTypeFieldForm
        fieldType={testFieldType}
        index={0}
        updateParentState={handleFieldInputChange}
        handleRemoveFieldClick={() => handleRemoveFieldClick}
      />,
    );
    cy.get('[cy-data="field_form_container"]')
      .should('be.visible')
      .within(() => {
        cy.contains('h5', 'Type');
        cy.contains('h5', 'Required?');
        cy.contains('h5', 'Array?');
        cy.contains('h5', 'Sample Options (If type=‘sample‘)');
        cy.contains('h5', 'Choices');
      });
  });
  describe('Field Name Input', () => {
    it('has field name header and input with placeholder text when fieldType is empty string', () => {
      mount(
        <SampleTypeFieldForm
          fieldType={testFieldType}
          index={0}
          updateParentState={cy.spy().as('handleChange')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );
      cy.get('[cy-data="field_form_container"]')
        .should('be.visible')
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
        <SampleTypeFieldForm
          fieldType={fieldType}
          index={0}
          updateParentState={cy.spy().as('handleChange')}
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
      const fieldType = testFieldType;
      const testName = 'Test Name';

      mount(
        <SampleTypeFieldForm
          fieldType={fieldType}
          index={0}
          updateParentState={cy.spy().as('handleChange')}
          handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
        />,
      );

      cy.get('[cy-data="field_form_container"]')
        .within(() => {
          cy.contains('h5', 'Field Name');
          cy.get('input[name="name"]')
            .type(testName)
            .trigger('change')
            .should('have.value', testName);

          cy.get('@handleChange').should((spy) => {
            expect(spy).to.have.been.called;
          });
        });
    });
  });
});
