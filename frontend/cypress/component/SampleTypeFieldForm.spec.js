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
    type: 'string',
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
        updateParentState={cy.spy().as('handleChange')}
        handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
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
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={() => cy.spy().as('handleChange')}
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
      const testName = 'Test Name';
      // const App = () => {
      //   const [fieldType, setFieldType] = React.useState(testFieldType);
      //   return (
      //     <>
      //       <SampleTypeField
      //         fieldType={fieldType}
      //         index={0}
      //         updateParentState={() => {
      //           const fieldTypeObj = { ...fieldType };
      //           fieldTypeObj.name = testName;
      //           setFieldType(fieldTypeObj);
      //           return null;
      //         }}
      //         handleRemoveFieldClick={() => cy.spy().as('handleRemoveFieldClick')}
      //       />
      //     </>
      //   );
      // };

      // mount(<App />);
      const updateParentState = cy.stub();
      mount(
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={updateParentState}
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

  describe('Field Type Input', () => {
    it('has field type header and type matches input prop', () => {
      mount(
        <SampleTypeField
          fieldType={testFieldType}
          index={0}
          updateParentState={cy.spy().as('handleChange')}
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
      // const updateParentState = cy.stub().returns(testFieldType.type = 'number');

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
});
