import React from 'react';
import {
  render, screen,
} from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import VerticalNavList from './VerticalNavList';

describe('VerticalNavList', () => {
  const mockOperationTypes = [
    {
      id: 17,
      name: 'Pour Gel',
      n: 1,
    },
    {
      id: 26,
      name: 'Transform Cells',
      n: 1,
    },
  ];

  const mockOperationType = {
    name: 'Pour Gel',
    operations: [
      {
        id: 1377,
        plan_id: 472,
        name: 'Josh Swore',
        status: 'pending',
        updated_at: '2020-11-19T18:36:57.000Z',
        inputs: '[]',
        outputs: [
          {
            id: 185081,
            name: 'Lane',
            role: 'output',
            sample_id: null,
            sample_name: null,
            object_type_name: null,
          },
        ],
        data_associations: [
          {
            id: 945733,
            object: '{"status_change":"Status changed to pending on 2020-11-19 by Aza Allen"}',
          },
        ],
      },
    ],
  };

  const mockGetOperations = jest.fn();

  const verticalNavList = () => render(
    <VerticalNavList
      name="mock-operation-types"
      list={mockOperationTypes}
      value={mockOperationType}
      getOperations={mockGetOperations}
    />,
  );

  it('should render with expected number of tabs in list from props', () => {
    verticalNavList();
    const tabs = screen.getAllByRole('tab');
    expect(tabs.length).toBe(2);
  });

  it('should call get operations on click', () => {
    verticalNavList();
    const tab = screen.getByRole('tab', { name: /Transform Cells/i });
    userEvent.click(tab);
    expect(mockGetOperations).toHaveBeenCalledTimes(1);
  });

  it('should have the correct selected tab', () => {
    verticalNavList();
    const tab = screen.getByRole('tab', { name: /(pour gel)/i });
    expect(tab).toHaveClass('Mui-selected');
  });

  it('should render when there are no operation types', () => {
    render(
      <VerticalNavList
        name="mock-operation-types"
        list={[]}
        value={{}}
        getOperations={mockGetOperations}
      />,
    );

    expect(screen.getByText(/no operations/i)).toBeInTheDocument();
  });
});
