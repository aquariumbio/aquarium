/*eslint-disable*/
import React from 'react';
import { render } from '@testing-library/react';
import { screen } from '@testing-library/dom';
import AnnouncementsTable from './AnnouncementsTable';

describe('Describes Announcements Table', () => {
  render(<AnnouncementsTable />);
  it('It renders without crashing', () => {
    expect(screen.getByRole('heading')).toHaveTextContent('Announcements');
  });

  it('Table can render values', () => {
    render(
      <AnnouncementsTable
        rowData={[{
          id: 1, title: 'Hello', message: 'First', active: true 
        },
        {
          id: 2, title: 'Goodbye', message: 'Second', active: true 
        },
        {
          id: 3, title: 'Hi', message: 'Third', active: true 
        }]}
      />,
    );

    const items = screen.queryAllByText(/true/);
    expect(items).toHaveLength(3);

    const rows = screen.queryAllByLabelText(/tr/);
    expect(rows[0]).toHaveTextContent('First');
    expect(rows[1]).toHaveTextContent('Second');
    expect(rows[2]).toHaveTextContent('Third');
  });
});
