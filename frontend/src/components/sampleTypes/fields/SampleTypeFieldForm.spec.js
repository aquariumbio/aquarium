import React from 'react';
import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import SampleTypeFieldForm from './SampleTypeFieldForm';

describe('SampleTypeFieldForm', () => {
  const emptyFieldType = {
    id: null,
    name: '',
    ftype: '',
    required: false,
    array: false,
    choices: '',
    allowableFieldTypes: [],
  };
  const sampleTypes = [{ name: 'sample-1' }, { name: 'sample-2' }];

  // Mock prop functions
  const mockUpdateParentState = jest.fn();
  const mockHandleRemoveFieldClick = jest.fn();
  const mockHandleAddAllowableFieldClick = jest.fn();

  const newFieldType = () =>
    render(
      <SampleTypeFieldForm
        fieldType={emptyFieldType}
        index={0}
        sampleTypes={sampleTypes}
        updateParentState={mockUpdateParentState}
        handleRemoveFieldClick={mockHandleRemoveFieldClick}
        handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
      />
    );

  // test that each field funcstions as expected
  describe('name field', () => {
    it('should render an empty field when fieldType is empty (new field type)', () => {
      newFieldType();

      expect(screen.getByRole('textbox', { name: 'name' }).value).toBe('');
    });

    it('should call updateParentState when the field is changed', () => {
      const userInput = 'New Name';

      newFieldType();

      const nameTextField = screen.getByRole('textbox', { name: 'name' });

      userEvent.type(nameTextField, userInput);
      userEvent.tab(); // change focus to trigger onBlur

      expect(mockUpdateParentState).toHaveBeenCalledTimes(1);
      expect(nameTextField.value).toBe(userInput);
    });
  });

  describe('field type select', () => {
    test('field should show "choose one" for new field types', () => {
      newFieldType();

      expect(within(screen.getByLabelText('ftype')).getByText('Choose one')).toBeInTheDocument();
    });

    it('should call updateParentState when changed', () => {
      newFieldType();
      const ftypeSelect = screen.getByLabelText('ftype');
      userEvent.click(ftypeSelect); // open select
      userEvent.click(screen.getByRole('option', { name: 'number' })); // make selection

      expect(within(ftypeSelect).getByText('number')).toBeInTheDocument();
      expect(mockUpdateParentState).toHaveBeenCalledTimes(1);
    });
  });

  describe('Required Chekcbox', () => {
    it('should be false for new field types', () => {
      newFieldType();

      expect(screen.getByRole('checkbox', { name: 'Required' }).checked).toBeFalsy();
    });

    it('should call updateParentState when changed', () => {
      newFieldType();
      const checkbox = screen.getByRole('checkbox', { name: 'Required' });

      userEvent.click(checkbox);

      expect(mockUpdateParentState).toHaveBeenCalledTimes(1);
    });

    it('should be true when checked', () => {
      newFieldType();
      const checkbox = screen.getByRole('checkbox', { name: 'Required' });

      userEvent.click(checkbox);

      expect(checkbox.value).toBeFalsy();
    });
  });

  describe('Array Chekcbox', () => {
    it('should be false for new field types', () => {
      newFieldType();

      expect(screen.getByRole('checkbox', { name: 'Array' }).checked).toBeFalsy();
    });

    it('should call updateParentState when changed', () => {
      newFieldType();
      const checkbox = screen.getByRole('checkbox', { name: 'Array' });

      userEvent.click(checkbox);

      expect(mockUpdateParentState).toHaveBeenCalledTimes(1);
    });

    it('should be true when checked', () => {
      newFieldType();
      const checkbox = screen.getByRole('checkbox', { name: 'Array' });

      userEvent.click(checkbox);

      expect(checkbox.value).toBeFalsy();
    });
  });

  describe('sample options', () => {
    describe('show N/A fieldType.ftype is not "sample"', () => {
      // Using test blocks rather than it blocks for readabilty
      test('ftype is not selected', () => {
        newFieldType();

        expect(screen.getByTestId('NA-samples')).toBeInTheDocument();
        // use queryBy when testing the absence of an element
        expect(screen.queryByRole('button', { name: 'Add option' })).not.toBeInTheDocument();
      });

      test('field type is url', () => {
        const testFieldType = {
          ...emptyFieldType,
          ftype: 'url',
        };
        render(
          <SampleTypeFieldForm
            fieldType={testFieldType}
            index={0}
            sampleTypes={sampleTypes}
            updateParentState={mockUpdateParentState}
            handleRemoveFieldClick={mockHandleRemoveFieldClick}
            handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
          />
        );

        expect(screen.getByTestId('NA-samples')).toBeInTheDocument();
        // use queryBy when testing the absence of an element
        expect(screen.queryByRole('button', { name: 'Add option' })).not.toBeInTheDocument();
      });
    });

    it('should show add field button when fieldType.ftype is "sample"', () => {
      const testFieldType = {
        ...emptyFieldType,
        ftype: 'sample',
      };
      render(
        <SampleTypeFieldForm
          fieldType={testFieldType}
          index={0}
          sampleTypes={sampleTypes}
          updateParentState={mockUpdateParentState}
          handleRemoveFieldClick={mockHandleRemoveFieldClick}
          handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
        />
      );

      expect(screen.queryByTestId('NA-samples')).not.toBeInTheDocument();
      // use queryBy when testing the absence of an element
      expect(screen.getByRole('button', { name: 'Add option' })).toBeInTheDocument();
    });

    it('should call updateParentState when add field button is pressed', () => {
      const testFieldType = {
        ...emptyFieldType,
        ftype: 'sample',
      };
      render(
        <SampleTypeFieldForm
          fieldType={testFieldType}
          index={0}
          sampleTypes={sampleTypes}
          updateParentState={mockUpdateParentState}
          handleRemoveFieldClick={mockHandleRemoveFieldClick}
          handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
        />
      );

      const button = screen.getByRole('button', { name: 'Add option' });

      userEvent.click(button);

      expect(mockHandleAddAllowableFieldClick).toHaveBeenCalledTimes(1);
    });

    it('should show "No sample types" when there are no sample types', () => {
      const noSampleTypes = [];
      const testFieldType = {
        ...emptyFieldType,
        ftype: 'sample',
      };
      render(
        <SampleTypeFieldForm
          fieldType={testFieldType}
          index={0}
          sampleTypes={noSampleTypes}
          updateParentState={mockUpdateParentState}
          handleRemoveFieldClick={mockHandleRemoveFieldClick}
          handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
        />
      );

      expect(screen.queryByText('No sample types')).toBeInTheDocument();
    });

    it.todo('should call updateParentState when a sample is selected from samples list');
  });

  describe('choices field', () => {
    describe('show show "N/A" when fieldType.ftype is not "string" or "number"', () => {
      // Using test blocks rather than it blocks for readabilty
      test('ftype is not selected, empty string', () => {
        newFieldType();

        expect(screen.getByTestId('NA-choices')).toBeInTheDocument();
        // use queryBy when testing the absence of an element
        expect(screen.queryByRole('textbox', { name: 'choices' })).not.toBeInTheDocument();
      });

      test('field type is url', () => {
        const testFieldType = {
          ...emptyFieldType,
          ftype: 'url',
        };
        render(
          <SampleTypeFieldForm
            fieldType={testFieldType}
            index={0}
            sampleTypes={sampleTypes}
            updateParentState={mockUpdateParentState}
            handleRemoveFieldClick={mockHandleRemoveFieldClick}
            handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
          />
        );

        expect(screen.getByTestId('NA-choices')).toBeInTheDocument();
        // use queryBy when testing the absence of an element
        expect(screen.queryByRole('textbox', { name: 'choices' })).not.toBeInTheDocument();
      });

      test('field type is sample', () => {
        const testFieldType = {
          ...emptyFieldType,
          ftype: 'sample',
        };
        render(
          <SampleTypeFieldForm
            fieldType={testFieldType}
            index={0}
            sampleTypes={sampleTypes}
            updateParentState={mockUpdateParentState}
            handleRemoveFieldClick={mockHandleRemoveFieldClick}
            handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
          />
        );

        expect(screen.getByTestId('NA-choices')).toBeInTheDocument();
        // use queryBy when testing the absence of an element
        expect(screen.queryByRole('textbox', { name: 'choices' })).not.toBeInTheDocument();
      });
    });

    it('should show textfield when field type is "string"', () => {
      const testFieldType = {
        ...emptyFieldType,
        ftype: 'string',
      };
      render(
        <SampleTypeFieldForm
          fieldType={testFieldType}
          index={0}
          sampleTypes={sampleTypes}
          updateParentState={mockUpdateParentState}
          handleRemoveFieldClick={mockHandleRemoveFieldClick}
          handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
        />
      );
      expect(screen.queryByTestId('NA-choices')).not.toBeInTheDocument(); // use queryBy when testing the absence of an element
      expect(screen.getByRole('textbox', { name: 'choices' })).toBeInTheDocument();
    });

    it('should show textfield when field type is "number"', () => {
      const testFieldType = {
        ...emptyFieldType,
        ftype: 'number',
      };
      render(
        <SampleTypeFieldForm
          fieldType={testFieldType}
          index={0}
          sampleTypes={sampleTypes}
          updateParentState={mockUpdateParentState}
          handleRemoveFieldClick={mockHandleRemoveFieldClick}
          handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
        />
      );
      expect(screen.queryByTestId('NA-choices')).not.toBeInTheDocument(); // use queryBy when testing the absence of an element
      expect(screen.getByRole('textbox', { name: 'choices' })).toBeInTheDocument();
    });

    it('should call updateParentState when a user types and changes focus in the field', () => {
      const testFieldType = {
        ...emptyFieldType,
        ftype: 'string',
      };
      render(
        <SampleTypeFieldForm
          fieldType={testFieldType}
          index={0}
          sampleTypes={sampleTypes}
          updateParentState={mockUpdateParentState}
          handleRemoveFieldClick={mockHandleRemoveFieldClick}
          handleAddAllowableFieldClick={mockHandleAddAllowableFieldClick}
        />
      );
      const textbox = screen.getByRole('textbox', { name: 'choices' });

      userEvent.type(textbox, 'user typing');
      userEvent.tab(); // change focus to trigger onBlur

      expect(mockUpdateParentState).toHaveBeenCalledTimes(1);
    });
  });

  describe('remove button', () => {
    it('should exist on the page when rendered', () => {
      newFieldType();
      expect(screen.getByRole('button', { name: 'remove-field' })).toBeInTheDocument();
    });

    it('should call handleRemoveClick on click', () => {
      newFieldType();
      userEvent.click(screen.getByRole('button', { name: 'remove-field' }));

      expect(mockHandleRemoveFieldClick).toHaveBeenCalledTimes(1);
    });

    it('should remove the field type container from page after click', () => {
      newFieldType();
      const removeFieldButton = screen.getByRole('button', { name: 'remove-field' });
      userEvent.click(removeFieldButton);

      waitFor(() => {
        expect(screen.queryByTestId('field-inputs')).not.toBeInTheDocument();
      });
    });
  });
});
