import React from 'react';
import { render, fireEvent, screen, waitFor } from '@testing-library/react';
import Modal from './Modal';

describe('Modal', () => {
  const testDetails = {
    title: 'Test Title',
    message: 'Test modal content',
    htmlId: 'test',
    btnText: 'Push Me',
  };


  it('should renders with button', () => {
    const { getByRole } = render(<Modal details={testDetails} />);

    expect(getByRole('button', { name: testDetails.btnText })).toHaveTextContent(testDetails.btnText);

    // Confirm modal content is not visible
    expect(screen.queryByText(testDetails.message)).toBeNull();
  });

  it('should trigger handle open on button press', async () => {
    const { getByRole } = render(<Modal details={testDetails} />);

  //  click button to open modal
    fireEvent.click(getByRole('button', { name: testDetails.btnText }));

    const modal = getByRole('dialog');

    // Wait for modal to open and check details
    await waitFor(() => {
      expect(modal).toBeInTheDocument();
      expect(modal).toHaveTextContent(testDetails.title);
      expect(modal).toHaveTextContent(testDetails.message);
    });

  });

  it('should remove modal from screen on escape', async () => {
    const { getByRole } = render(<Modal details={testDetails} />);

    //  click button to open modal
    fireEvent.click(getByRole('button', { name: testDetails.btnText }));

    const modal = getByRole('dialog');

    // Wait for modal to open
    await waitFor(() => {
      expect(modal).toBeInTheDocument();
    });

    // simulate escape press
    fireEvent.keyDown(modal, {
      key: 'Escape',
      keyCode: 'Escape',
      which: 27,
    });

    // wait to check that the modal is removed from the screen
    await waitFor(() => {
      expect(modal).not.toBeInTheDocument();
    });
  });
});
