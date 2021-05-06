import React from 'react';
import {
  render, screen, waitForElementToBeRemoved, within,
} from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import SideBar from './SideBar';

describe('SideBar', () => {
  const mockJobCounts = {
    assigned: 7,
    unassigned: 190,
    finished: 28122,
  };

  const mockActiveCategories = {
    Cloning: 7613,
    'Cloning Sandbox': 599,
    'Control Blocks': 12,
    'Flow Cytometry': 68,
    'High Throughput Culturing': 43,
    'Misc.': 331,
  };

  const mockInactiveCategories = [
    'Agrobacterium work',
    'Induction - High Throughput',
    'Misc. (old)',
  ];
  const mockValue = 'unassigned';
  const mockSetValue = jest.fn();
  const mockCategory = '';
  const mockSetCategory = jest.fn();

  const sideBar = () => render(
    <SideBar
      jobCounts={mockJobCounts}
      activeCounts={mockActiveCategories}
      inactive={mockInactiveCategories}
      value={mockValue}
      setValue={mockSetValue}
      category={mockCategory}
      setCategory={mockSetCategory}
    />,
  );

  it('should render with expected assigned job counts', () => {
    sideBar();

    screen.getByRole('tab', { name: /assigned \(7\)/i });
  });

  it('should render with expected unassigned job counts selected', () => {
    sideBar();

    expect(screen.getByRole('tab', { name: /unassigned \(190\)/i })).toHaveClass('Mui-selected');
  });

  it('should render with expected finished job counts', () => {
    sideBar();

    screen.getByRole('tab', { name: /finished \(28122\)/i });
  });

  it('should render with expected operations', () => {
    sideBar();

    screen.getByRole('tab', { name: /Cloning \(7613\)/i });
    screen.getByRole('tab', { name: /Cloning Sandbox \(599\)/i });
    screen.getByRole('tab', { name: /Flow Cytometry \(68\)/i });
    screen.getByRole('tab', { name: /Control Blocks \(12\)/i });
    screen.getByRole('tab', { name: /High Throughput Culturing \(43\)/i });
    screen.getByRole('tab', { name: /Misc. \(331\)/i });
  });

  it('should call setValue on tab click', () => {
    sideBar();

    userEvent.click(screen.getByRole('tab', { name: /Assigned/ }));

    expect(mockSetValue).toHaveBeenCalledTimes(1);
  });

  it('should call setCategory on tab click', () => {
    sideBar();

    userEvent.click(screen.getByRole('tab', { name: /Assigned/ }));

    expect(mockSetCategory).toHaveBeenCalledTimes(1);
  });

  it('should render with collapsed inactive list', () => {
    sideBar();

    screen.getByRole('button', { name: /inactive/i });

    expect(screen.queryByRole('tab', { name: /Agrobacterium work/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('tab', { name: /Induction - High Throughput/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('tab', { name: /Misc. \(old\)/i })).not.toBeInTheDocument();
  });

  it('should inactive list should open on fist click then close on next click', async () => {
    sideBar();

    userEvent.click(screen.getByRole('button', { name: /inactive/i }));

    screen.getByRole('tab', { name: /Agrobacterium work/i });
    screen.getByRole('tab', { name: /Induction - High Throughput/i });
    screen.getByRole('tab', { name: /Misc. \(old\)/i });

    userEvent.click(screen.getByRole('button', { name: /inactive/i }));

    await waitForElementToBeRemoved(screen.queryByRole('tab', { name: /Agrobacterium work/i }));
    expect(screen.queryByRole('tab', { name: /Induction - High Throughput/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('tab', { name: /Misc. \(old\)/i })).not.toBeInTheDocument();
  });

  describe('no active jobs', () => {
    const testSidebar = () => render(
      <SideBar
        jobCounts={mockJobCounts}
        activeCounts={{}}
        inactive={mockInactiveCategories}
        value={mockValue}
        setValue={mockSetValue}
        category={mockCategory}
        setCategory={mockSetCategory}
      />,
    );
    it('should not have any category tabs, inactive list is collapsed', () => {
      testSidebar();
      const tablist = screen.getByRole('tablist', { name: /categories/ });
      const tabs = within(tablist).queryByRole('tab');
      expect(tabs).not.toBeInTheDocument();
    });

    it('should have category tabs, inactive list is expanded', () => {
      testSidebar();
      const tablist = screen.getByRole('tablist', { name: /categories/ });
      userEvent.click(screen.getByRole('button', { name: /inactive/i }));

      const tabs = within(tablist).getAllByRole('tab');
      expect(tabs.length).toBeGreaterThan(0);
    });
  });
});
