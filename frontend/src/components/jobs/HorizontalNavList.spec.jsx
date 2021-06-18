import React from 'react';
import {
  render, screen,
} from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import HorizontalNavList from './HorizontalNavList';

describe('HorizontalNavList', () => {
  const mockName = 'mock-operation-states';
  const mockList = [
    { name: 'Pending' },
  ];
  const mockValue = 'Pending';
  const mockSetValue = jest.fn();
  const mockCount = 4;

  const horizontalNavList = () => render(
    <HorizontalNavList
      name={mockName}
      list={mockList}
      value={mockValue}
      setValue={mockSetValue}
      count={mockCount}
    />,
  );

  it('should render with expected number of tabs in list from props', () => {
    horizontalNavList();
    const tabs = screen.getAllByRole('tab');
    expect(tabs.length).toBe(1);
  });

  it('should call get operations on click', () => {
    horizontalNavList();
    const tab = screen.getByRole('tab');
    userEvent.click(tab);
    expect(mockSetValue).toHaveBeenCalledTimes(1);
  });

  it('should have the correct selected tab', () => {
    horizontalNavList();
    const tab = screen.getByRole('tab', { name: /(pending)/i });
    expect(tab).toHaveClass('Mui-selected');
  });
});
