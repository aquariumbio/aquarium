/* eslint-disable */ 
import React from 'react';
import { render } from '@testing-library/react';
import AnnouncementsPage from './AnnouncementsPage';

describe('Describes Announcements page', () => {
  it('It renders without crashing', () => {
    const { asFragment } = render(
      <AnnouncementsPage />
    );
    const firstRender = asFragment();
    expect(firstRender).toMatchSnapshot();
  });
});
