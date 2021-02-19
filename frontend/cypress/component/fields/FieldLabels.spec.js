/// <reference types="cypress" />
import React from 'react';
import { mount } from '@cypress/react';
import FieldLabels from '../../../src/components/sampleTypes/fields/FieldLabels';

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
          .contains('h4', 'Sample Options');

        cy.get('[data-cy="field-choices-label-div"]')
          .should('be.visible')
          .contains('h4', 'Choices');
      });
  });
});
