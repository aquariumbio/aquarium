import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import WindowDimensionsProvider from '../../WindowDimensionsProvider';
import jobsAPI from '../../helpers/api/jobsAPI';
import ShowFinished from './ShowFinished';

// TODO: mock API return
// eslint-disable-next-line no-unused-vars
const mockJobs = [
  {
    assigned_date: null,
    category: 'Yeast Display',
    created_at: '2021-03-03T18:00:44.000Z',
    deployed: 1,
    id: '117881-363',
    job_id: 117881,
    name: 'Challenge and Label',
    operation_type_id: 363,
    operations_count: 4,
    pc: -2,
    to_login: null,
    to_name: null,
    updated_at: '2021-03-03T18:03:48.000Z',
  },
  {
    assigned_date: null,
    category: 'Yeast Display',
    created_at: '2021-03-03T17:57:21.000Z',
    deployed: 1,
    id: '117880-363',
    job_id: 117880,
    name: 'Challenge and Label',
    operation_type_id: 363,
    operations_count: 2,
    pc: -2,
    to_login: null,
    to_name: null,
    updated_at: '2021-03-03T17:57:36.000Z',
  },
  {
    assigned_date: null,
    category: 'Yeast Display',
    created_at: '2021-03-03T17:56:37.000Z',
    deployed: 1,
    id: '117879-363',
    job_id: 117879,
    name: 'Challenge and Label',
    operation_type_id: 363,
    operations_count: 2,
    pc: -2,
    to_login: null,
    to_name: null,
    updated_at: '2021-03-03T17:57:02.000Z',
  },
];

describe('ShowFinished component', () => {
  const tabletWidth = 1280;
  const mockWindowDimensions = {
    height: 976,
    width: 1920,
    tablet: window.innerWidth <= tabletWidth,
  };

  const showFinished = () => render(
    <WindowDimensionsProvider value={mockWindowDimensions}>
      <ShowFinished />
    </WindowDimensionsProvider>,
  );

  it('should make api call when rendered', () => {
    const getFinishedSpy = jest.spyOn(jobsAPI, 'getFinished');

    showFinished();
    expect(getFinishedSpy).toHaveBeenCalled();
  });

  it('should make api call when date range is changed', () => {
    const getFinishedSpy = jest.spyOn(jobsAPI, 'getFinished');

    showFinished();
    // expect(getFinishedSpy).toHaveBeenCalled();
    userEvent.click(screen.getByRole('button', { name: /seven-days-input/i }));
    userEvent.click(screen.getByRole('option', { name: /last 7 days/i }));
    expect(getFinishedSpy).toHaveBeenNthCalledWith(1, '0');
    expect(getFinishedSpy).toHaveBeenNthCalledWith(2, '1');
  });
});
