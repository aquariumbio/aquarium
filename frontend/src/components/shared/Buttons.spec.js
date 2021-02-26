import React from 'react';
import {render, screen, fireEvent} from '@testing-library/react'
import { Router } from 'react-router-dom';
import { createMemoryHistory } from 'history';
import {StandardButton, LinkButton} from './Buttons';

describe('StandardButton', () => {
  it('should render with expected text', () => {
    const mockHandleClick = jest.fn();
    render(<StandardButton name="test-button" text="Click Me!" handleClick={mockHandleClick} />);

    expect(screen.getByRole('button')).toHaveTextContent('Click Me!');
  });

  it('should trigger onClickHandler when clicked', () => {
    const mockHandleClick = jest.fn();
    render(<StandardButton name="test-button" text="Click Me!" handleClick={mockHandleClick} />);

    fireEvent.click(screen.getByRole('button', {name: 'Click Me!'}));

    expect(mockHandleClick).toHaveBeenCalledTimes(1);
  });
});

describe('LinkButton', () => {
  it('should render with expected text', () => {
    const history = createMemoryHistory();

    // mock push function
    history.push = jest.fn();

    render(
      <Router history={history}>
        <LinkButton name="test-link-button" text="Click Me!" linkTo="/test" />
      </Router>,
    );

    expect(screen.getByRole('button', { name: 'Click Me!' }))
      .toHaveAttribute('href','/test');

  });

  it('routes to a new route', async () => {
    const history = createMemoryHistory();

    // mock push function
    history.push = jest.fn();

    render(
      <Router history={history}>
        <LinkButton name="test-link-button" text="Click Me!" linkTo="/test" />
      </Router>,
    );

    fireEvent.click(screen.getByRole('button', { name: 'Click Me!' }));

    expect(history.push).toHaveBeenCalledWith('/test');
  });
});
