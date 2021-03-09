import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import LoadingSpinner from './LoadingSpinner';

describe('Name of the group', () => {
  it('should be visible when isLoading is true', async () => {
    const testTrue = true;
    render(<LoadingSpinner isLoading={testTrue} />);

    const loadingSpinner = screen.getByTestId('loading');
    expect(loadingSpinner).toBeInTheDocument();
    expect(loadingSpinner).toBeVisible();
  });

  it('should be not visible when isLoading is false', async () => {
    const testFalse = false;
    render(<LoadingSpinner isLoading={testFalse} />);

    const loadingSpinner = screen.getByTestId('loading');
    expect(loadingSpinner).toBeInTheDocument();
    expect(loadingSpinner).toHaveAttribute('aria-hidden', 'true');
  });
});
