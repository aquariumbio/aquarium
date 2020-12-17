/// <reference types="cypress" />
import React from 'react';
import { mount } from 'cypress-react-unit-test';
import { BrowserRouter as Router } from 'react-router-dom';
import { StandardButton, LinkButton } from '../../src/components/shared/Buttons';

describe('StandardButton', () => {
  beforeEach(() => {
    mount(
      <StandardButton
        name="test-btn"
        text="standard button"
        dark
        dense
        handleClick={cy.spy().as('handleClick')}
        testName="test-btn"
      />,
    );
  });

  it('renders the button', () => {
    cy.get('[data-cy="test-btn"]')
      .should('have.attr', 'type', 'button');
  });

  it('calls handleClick when clicked', () => {
    // Find button and click it
    cy.get('[data-cy="test-btn"]')
      .click();

    // Get handleClick spy verify it was called
    cy.get('@handleClick')
      .should('have.been.calledOnce');
  });
});

describe('LinkButton', () => {
  beforeEach(() => {
    mount(
      // Links cannot be used outside a Router so we mount it inside one for our test environment
      <Router>
        <LinkButton
          name="test-btn"
          text="link button"
          dark
          dense
          linkTo="/test"
          testName="test-btn"
        />
      </Router>,
    );
  });

  it('renders the button', () => {
    cy.get('[data-cy="test-btn"]')
      .should('have.attr', 'href', '/test');
  });

  it('routes when clicked', () => {
    // Find button and click it
    cy.get('[data-cy="test-btn"]').click();

    // assert location has changed
    cy.location('pathname').should('eq', '/test');
  });
});
