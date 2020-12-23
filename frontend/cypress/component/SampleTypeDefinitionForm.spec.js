/// <reference types="cypress" />
import React from 'react';
import { mount } from 'cypress-react-unit-test';
import { BrowserRouter as Router } from 'react-router-dom';
import SampleTypeDefinitionForm from '../../src/components/sampleTypes/SampeTypeDefinitionForm';

describe('Sample Type Definition Form', () => {
  describe('New', () => {
    // after(() => {
    //   unmount('@SampleTypeDefinitionForm');
    // });
    const match = {
      url: '/sample_types/new',
      isExact: true,
      params: { id: null },
      path: '/sample_types/new',
    };
    beforeEach(() => {
      cy.login();
      mount(
        <Router>
          <SampleTypeDefinitionForm match={match} />
        </Router>,
      );
    });

    it('renders fields form container', () => {
      cy.get('[data-cy="sampe-type-definition-container"]')
        .should('be.visible')
        .within(() => {
          cy.get('[data-cy="ladoing-backdrop"]').should('not.be.visible');
          cy.get('[data-cy="sampe-type-definition-form"]');
          cy.contains('h1', 'Defining New Sample Type');
          cy.contains('p', '* field is required');

          cy.contains('h4', 'Name');
          cy.get('[data-cy="sample-type-name-input"]');

          cy.contains('h4', 'Description');
          cy.get('[data-cy="sample-type-description-input"]');

          cy.get('button[name="add-new-field"]');
        });
    });

    context('name input', () => {
      it('accepts user input', () => {
        const userInput = 'Boop';
        cy.get('[data-cy="sample-type-name-input"]')
          .type(userInput)
          .should('have.value', userInput);
      });
    });

    context('description input', () => {
      it('accepts user input', () => {
        const userInput = 'Boop';
        cy.get('input[id="sample-type-description-input"]')
          .type(userInput)
          .should('have.value', userInput);
      });
    });

    context('add new field button', () => {
      it('adds field onclick', () => {
        cy.get('[data-cy="fields-container"]')
          .get('[data-cy="field-inputs"]')
          .its('length')
          .then((size) => {
            cy.get('button[name="add-new-field"]')
              .click();
            cy.get('[data-cy="field-inputs"]')
              .its('length').should('be.greaterThan', size);
          });
      });
    });
  });

  describe('Edit', () => {
    const match = {
      isExact: true,
      params: { id: '54' },
      path: '/sample_types/:id/edit',
      url: '/sample_types/54/edit',
    };
    beforeEach(() => {
      cy.login();
      mount(
        <Router>
          <SampleTypeDefinitionForm match={match} />
        </Router>,
      );
    });
    context('all(back) button', () => {
      it('changes route onclick', () => {
        cy.url().should('include', '/sample_types/').and('include', '/edit');
        cy.get('[data-cy="back"]')
          .click()
          .then(() => {
            cy.url().should('not.include', '/edit');
          });
      });
    });
  });
});
