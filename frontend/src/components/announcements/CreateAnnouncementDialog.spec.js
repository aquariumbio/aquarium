/*eslint-disable*/
import React from 'react';
import { render } from '@testing-library/react';
import { screen } from '@testing-library/dom';
import CreateAnnouncementDialog from './CreateAnnouncementDialog';

describe('Describes Announcements Dialog', () => {
  it('It renders without crashing', () => {
    render(<CreateAnnouncementDialog />);
    expect(screen.getByRole('heading')).toHaveTextContent('Create Announcements');
  });

  it('Form can receive user input', () => {
    render(<CreateAnnouncementDialog />);
  });
});
