import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import TextInput from './TextInput';

describe('TextInput', () => {
  const testName = 'testInput';
  const mockHandleChange = jest.fn()
  const testValue = '';

  it('has empty input when value is empty ', () => {
    const { getByTestId } = render(
      <TextInput name={testName} value={testValue} handleChange={mockHandleChange} />,
    );

    expect(getByTestId(testName).value).toBe('');
  });

  it("triggers event handler on input change", () => {
    const userInput = 'testing user input';
    const { getByTestId, rerender } = render(
      <TextInput name={testName} value={testValue} handleChange={mockHandleChange} />,
    );

    fireEvent.change(getByTestId(testName), {
      target: { value: userInput },
    });

    fireEvent.blur(getByTestId(testName));

    rerender(<TextInput name={testName} value={userInput} handleChange={mockHandleChange} />);

    expect(getByTestId(testName).value).toBe(userInput);
    expect(mockHandleChange).toBeCalledTimes(1);
  });
});
