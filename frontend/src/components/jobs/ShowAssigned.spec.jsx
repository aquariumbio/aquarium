import React from 'react';
import { render } from '@testing-library/react';
import WindowDimensionsProvider from '../../WindowDimensionsProvider';
import jobsAPI from '../../helpers/api/jobsAPI';
import ShowAssigned from './ShowAssigned';

describe('ShowAssigned component', () => {
  const tabletWidth = 1280;
  const mockWindowDimensions = {
    height: 976,
    width: 1920,
    tablet: window.innerWidth <= tabletWidth,
  };
  const showAssigned = () => render(
    <WindowDimensionsProvider value={mockWindowDimensions}>
      <ShowAssigned />
    </WindowDimensionsProvider>,
  );

  it('should make api call when rendered', () => {
    const getAssignedSpy = jest.spyOn(jobsAPI, 'getAssigned');

    showAssigned();
    expect(getAssignedSpy).toHaveBeenCalled();
  });
});
