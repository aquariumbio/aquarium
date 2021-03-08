import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import TextInput from './TextInput';

describe('TextInput', () => {
  const mockHandleChange = jest.fn();
  const testValue = '';

  it('has empty input when value is empty ', () => {
    const { getByTestId } = render(
      <TextInput name="Text Input" value={testValue} handleChange={mockHandleChange} />,
    );

    expect(getByTestId('Text Input').value).toBe('');
  });

  it('triggers event handler on input change', () => {
    const userInput = 'testing user input';
    const { getByTestId, rerender } = render(
      <TextInput name="Text Input" value={testValue} handleChange={mockHandleChange} />,
    );

    fireEvent.change(getByTestId('Text Input'), {
      target: { value: userInput },
    });

    fireEvent.blur(getByTestId('Text Input'));

    rerender(<TextInput name="Text Input" value={userInput} handleChange={mockHandleChange} />);

    expect(getByTestId('Text Input').value).toBe(userInput);
    expect(mockHandleChange).toBeCalledTimes(1);
  });
});
