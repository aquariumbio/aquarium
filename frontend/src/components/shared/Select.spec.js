import React from 'react';
import { render, fireEvent, within } from '@testing-library/react';
import Select from './Select';

describe('Select', () => {
  const testName = 'test';
  const testValue = '';
  const mockHandleChange = jest.fn();
  const testOptions = [
    {
      name: 'One',
      value: '1',
    },
    {
      name: 'Two',
      value: '2',
    },
  ]

  it('has false value when no option is selected ', () => {
    const { getByTestId } = render(
      <Select
        name={testName}
        handleChange={mockHandleChange}
        value={testValue}
        options={testOptions}
      />,
    );

    expect(getByTestId('select-input').value).toBe('');
  });

  it('triggers event handler on select', () => {
    const userInput = 'Two';
    const {getByRole} = render(
      <Select
        name={testName}
        handleChange={mockHandleChange}
        value={testValue}
        options={testOptions}
      />,
    );

    fireEvent.mouseDown(getByRole('button')); // open menu

    const listbox = within(getByRole('listbox')); // get list of options
    const optionsList = listbox.getAllByRole('option');

    expect(optionsList).toHaveLength(3);

    fireEvent.click(listbox.getByText(userInput)); // select option
    expect(mockHandleChange).toBeCalledTimes(1);
  });
})
