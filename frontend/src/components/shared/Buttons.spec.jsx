import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Router } from 'react-router-dom';
import { createMemoryHistory } from 'history';
import { StandardButton, LinkButton, HomeButton } from './Buttons';

describe('StandardButton', () => {
  it('should render with expected text', () => {
    const mockHandleClick = jest.fn();
    render(<StandardButton name="test-button" text="Click Me!" handleClick={mockHandleClick} />);

    expect(screen.getByRole('button')).toHaveTextContent('Click Me!');
  });

  it('should trigger onClickHandler when clicked', () => {
    const mockHandleClick = jest.fn();
    render(<StandardButton name="test-button" text="Click Me!" handleClick={mockHandleClick} />);

    fireEvent.click(screen.getByRole('button', { name: 'Click Me!' }));

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

    expect(screen.getByRole('button', { name: 'Click Me!' })).toHaveAttribute('href', '/test');
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

  describe('Home button', () => {
    it('should render with logo', () => {
      const history = createMemoryHistory();

      render(
        <Router history={history}>
          <HomeButton />
        </Router>,
      );
      expect(screen.queryByRole('img', { name: 'logo' })).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'home' })).toHaveAttribute('href', '/');
    });

    it('should route to home on click', () => {
      const history = createMemoryHistory();

      // mock push function
      history.push = jest.fn();

      render(
        <Router history={history}>
          <HomeButton />
        </Router>,
      );

      fireEvent.click(screen.getByRole('button', { name: 'home' }));

      expect(screen.getByRole('button', { name: 'home' })).toHaveAttribute('href', '/');
      expect(history.push).toHaveBeenCalledWith('/');
    });
  });
});
