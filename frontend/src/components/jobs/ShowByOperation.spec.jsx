import React from 'react';
import {
  render,
} from '@testing-library/react';
import ShowByOperation from './ShowByOperation';
import WindowDimensionsProvider from '../../WindowDimensionsProvider';
import jobsAPI from '../../helpers/api/jobsAPI';

describe('ShowByOperation Component', () => {
  const mockCategory = 'Cloning';
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
  const mockSetOperationType = jest.fn();
  const mockSetPendingCount = jest.fn();
  const mockSetAlertProps = jest.fn();

  const tabletWidth = 1280;
  const mockWindowDimensions = {
    height: 976,
    width: 1920,
    tablet: window.innerWidth <= tabletWidth,
  };

  const showByOperation = () => render(
    <WindowDimensionsProvider value={mockWindowDimensions}>
      <ShowByOperation
        category={mockCategory}
        operationType={mockOperationType}
        setOperationType={mockSetOperationType}
        setPendingCount={mockSetPendingCount}
        setAlertProps={mockSetAlertProps}
      />
    </WindowDimensionsProvider>,
  );

  it('should make api call when rendered', () => {
    const spy = jest.spyOn(jobsAPI, 'getCategoryByStatus');

    showByOperation();
    expect(spy).toHaveBeenCalled();
  });
});
