/// <reference types="cypress" />
import React from 'react';
import { mount, unmount } from 'cypress-react-unit-test';
import SampleTypeDefinitionForm from '../../src/components/sampleTypes/SampeTypeDefinitionForm';

describe('Sample Type Definition Form', () => {
  describe('New', () => {
    after(() => {
      unmount('@SampleTypeDefinitionForm');
    });

    it('renders fields form container', () => {
      mount(<SampleTypeDefinitionForm />);
      cy.get('[cy-data="field_form_container"]')
        .should('be.visible')
        .within(() => {
          cy.contains('h1', 'Defining New Sample Type');
          cy.contains('p', '* field is required');
          cy.contains('h4', 'Name');
          cy.get('input[id="sample_type_name_input"]');
          cy.contains('h4', 'Description');
          cy.get('input[id="sample_type_description_input"]');
          cy.get('button[name="add_new_field"]');
          cy.get('[cy-data="field_form_container"]')
            .find('div[name="field_inputs"]')
            .should('have.length', 1);
        });
    });

    context('name input', () => {
      it('accepts user input', () => {
        const userInput = 'Boop';
        mount(<SampleTypeDefinitionForm />);
        cy.get('input[id="sample_type_name_input"]')
          .type(userInput)
          .should('have.value', userInput);
      });
    });

    context('description input', () => {
      it('accepts user input', () => {
        const userInput = 'Boop';
        mount(<SampleTypeDefinitionForm />);
        cy.get('input[id="sample_type_description_input"]')
          .type(userInput)
          .should('have.value', userInput);
      });
    });

    context('add new field button', () => {
      it('adds field onclick', () => {
        mount(<SampleTypeDefinitionForm />);
        cy.get('[cy-data="field_form_container"]')
          .find('div[name="field_inputs"]')
          .should('have.length', 1);

        cy.get('button[name="add_new_field"]')
          .click();

        cy.get('[cy-data="field_form_container"]')
          .find('div[name="field_inputs"]')
          .should('have.length', 2);
      });
    });
  });
});
