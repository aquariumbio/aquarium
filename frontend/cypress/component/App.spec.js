/// <reference types="cypress" />
/* eslint-disable react/jsx-filename-extension */
import React from 'react';
// eslint-disable-next-line import/no-extraneous-dependencies
import { mount } from 'cypress-react-unit-test';
import { BrowserRouter as Router } from 'react-router-dom';
import App from '../../src/components/app/App';

describe('App', () => {
  it('renders app container', () => {
    mount(
      <Router>
        <App />
      </Router>,
    );
    cy.get('[data-cy="app-container"]')
      .should('be.visible');
  });
});
