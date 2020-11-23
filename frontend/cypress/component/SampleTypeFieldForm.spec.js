/// <reference types="cypress" />
/* eslint-disable react/jsx-filename-extension */
import React from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import { mount } from 'cypress-react-unit-test';
// import { BrowserRouter as Router } from 'react-router-dom';
import SampleTypeFieldForm from '../../src/components/sampleTypes/SampleTypeFieldForm';

describe('SampleTypeFieldForm', () => {
  it('renders container and all field headers', () => {
    const testFieldType = {
      id: null,
      name: '',
      type: 'string',
      isRequired: false,
      isArray: false,
      choices: '',
    };
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
        cy.contains('h5', 'Field Name');
        cy.contains('h5', 'Type');
        cy.contains('h5', 'Required?');
        cy.contains('h5', 'Array?');
        cy.contains('h5', 'Sample Options (If type=‘sample‘)');
        cy.contains('h5', 'Choices');
      });
  });

  // it('renders container and all field headers', () => {
  //   const testFieldType = {
  //     id: null,
  //     name: '',
  //     type: 'string',
  //     isRequired: false,
  //     isArray: false,
  //     choices: '',
  //   };
  //   const handleFieldInputChange = cy.stub();
  //   const handleRemoveFieldClick = cy.stub();
  //   mount(
  //     <SampleTypeFieldForm
  //       fieldType={testFieldType}
  //       index={0}
  //       updateParentState={handleFieldInputChange}
  //       handleRemoveFieldClick={() => handleRemoveFieldClick}
  //     />,
  //   );
  //   cy.get('[cy-data="field_form_container"]')
  //     .should('be.visible')
  //     .within(() => {
  //       cy.contains('h5', 'Field Name');
  //       cy.get('[cy-data="field_name_input"]')
  //         .should('have.attr', 'placeholder', 'Field name');

  //       cy.contains('h5', 'Type');
  //       cy.get('[cy-data="field_type_select"]');

  //       cy.contains('h5', 'Required?');
  //       cy.get('[data-cy=isRequired_checkbox]');

  //       cy.contains('h5', 'Array?');
  //       cy.get('[data-cy=isArray_checkbox]');
  //     });
  // });
});
