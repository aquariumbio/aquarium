import React from 'react';
import { render, screen, waitForElementToBeRemoved } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import SideBar from './SideBar';

describe('SideBar', () => {
  const mockJobCounts = {
    assigned: 7,
    unassigned: 190,
    finished: 28122,
  };

  const mockActiveCounts = {
    Cloning: 7613,
    'Cloning Sandbox': 599,
    'Control Blocks': 12,
    'Flow Cytometry': 68,
    'High Throughput Culturing': 43,
    'Misc.': 331,
  };

  const mockInactive = [
    'Agrobacterium work',
    'Induction - High Throughput',
    'Misc. (old)',
  ];
  const mockValue = 'unassigned';
  const mockSetValue = jest.fn();

  const sideBar = () => render(
    <SideBar
      jobCounts={mockJobCounts}
      activeCounts={mockActiveCounts}
      inactive={mockInactive}
      value={mockValue}
      setValue={mockSetValue}
    />,
  );

  it('should render with expected assigned job counts', () => {
    sideBar();

    screen.getByRole('button', { name: /assigned \(7\)/i });
  });

  it('should render with expected unassigned job counts selected', () => {
    sideBar();

    expect(screen.getByRole('button', { name: /unassigned \(190\)/i })).toHaveClass('Mui-selected');
  });

  it('should render with expected finished job counts', () => {
    sideBar();

    screen.getByRole('button', { name: /finished \(28122\)/i });
  });

  it('should render with expected operations', () => {
    sideBar();

    screen.getByRole('button', { name: /Cloning \(7613\)/i });
    screen.getByRole('button', { name: /Cloning Sandbox \(599\)/i });
    screen.getByRole('button', { name: /Flow Cytometry \(68\)/i });
    screen.getByRole('button', { name: /Control Blocks \(12\)/i });
    screen.getByRole('button', { name: /High Throughput Culturing \(43\)/i });
    screen.getByRole('button', { name: /Misc. \(331\)/i });
  });

  it('should call setValue on button click', () => {
    sideBar();

    userEvent.click(screen.getByRole('button', { name: /Assigned/ }));

    expect(mockSetValue).toHaveBeenCalledTimes(1);
  });

  it('should render with collapsed inactive list', () => {
    sideBar();

    screen.getByRole('button', { name: /inactive/i });

    expect(screen.queryByRole('button', { name: /Agrobacterium work/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /Induction - High Throughput/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /Misc. \(old\)/i })).not.toBeInTheDocument();
  });

  it('should inactive list should open on fist click then close on next click', async () => {
    sideBar();

    userEvent.click(screen.getByRole('button', { name: /inactive/i }));

    screen.getByRole('button', { name: /Agrobacterium work/i });
    screen.getByRole('button', { name: /Induction - High Throughput/i });
    screen.getByRole('button', { name: /Misc. \(old\)/i });

    userEvent.click(screen.getByRole('button', { name: /inactive/i }));

    await waitForElementToBeRemoved(screen.queryByRole('button', { name: /Agrobacterium work/i }));
    expect(screen.queryByRole('button', { name: /Induction - High Throughput/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /Misc. \(old\)/i })).not.toBeInTheDocument();
  });
});
