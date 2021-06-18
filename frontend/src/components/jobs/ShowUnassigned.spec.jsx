import React from 'react';
import { render } from '@testing-library/react';
import WindowDimensionsProvider from '../../WindowDimensionsProvider';
import jobsAPI from '../../helpers/api/jobsAPI';
import ShowUnassigned from './ShowUnassigned';

describe('ShowUnassigned component', () => {
  const tabletWidth = 1280;
  const mockWindowDimensions = {
    height: 976,
    width: 1920,
    tablet: window.innerWidth <= tabletWidth,
  };
  const showUnassigned = () => render(
    <WindowDimensionsProvider value={mockWindowDimensions}>
      <ShowUnassigned />
    </WindowDimensionsProvider>,
  );

  it('should make api call when rendered', () => {
    const getUnassignedSpy = jest.spyOn(jobsAPI, 'getUnassigned');

    showUnassigned();
    expect(getUnassignedSpy).toHaveBeenCalled();
  });
});
