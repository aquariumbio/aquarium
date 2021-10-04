import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ShowJobOperations from './ShowJobOperations';
import WindowDimensionsProvider from '../../WindowDimensionsProvider';

describe('ShowJobOperations', () => {
  const mockOperations = [
    {
      id: 163112,
      operation_id: 289759,
      updated_at: '2020-06-11T04:32:28.000Z',
      status: 'scheduled',
      plan_id: 40034,
      inputs: [
        {
          id: 1066379,
          name: 'Forward Primer',
          role: 'input',
          sample_id: 32992,
          sample_name: 'L1-TetR-TP-forward primer',
          object_type_name: 'Primer Aliquot',
        },
        {
          id: 1066380,
          name: 'Reverse Primer',
          role: 'input',
          sample_id: 32993,
          sample_name: 'L1-TetR-TP-reverse primer',
          object_type_name: 'Primer Aliquot',
        },
        {
          id: 1066381,
          name: 'Template',
          role: 'input',
          sample_id: 20363,
          sample_name: 'Bak_template',
          object_type_name: 'test',
        },
      ],
      outputs: [
        {
          id: 1066382,
          name: 'Fragment',
          role: 'output',
          sample_id: 34459,
          sample_name: "Yokesh's Fragment",
          object_type_name: 'Stripwell',
        },
      ],
      data_associations: [
        {
          id: 943063,
          object: '{"status_change":"Status changed to pending on 2020-06-11 by Justin La"}',
        },
        {
          id: 943060,
          object: '{"aborted":"Operation was canceled when job 117487 was aborted"}',
        },
        {
          id: 943054,
          object: '{"precondition_warnings":""}',
        },
      ],
    },
    {
      id: 163114,
      operation_id: 289761,
      updated_at: '2020-06-11T04:31:28.000Z',
      status: 'scheduled',
      plan_id: 40034,
      inputs: [
        {
          id: 1066387,
          name: 'Forward Primer',
          role: 'input',
          sample_id: 12951,
          sample_name: 'TP_tADH1_F',
          object_type_name: 'Primer Aliquot',
        },
        {
          id: 1066388,
          name: 'Reverse Primer',
          role: 'input',
          sample_id: 32815,
          sample_name: 'Primer_CS_6b3eb3e9',
          object_type_name: 'Primer Aliquot',
        },
        {
          id: 1066389,
          name: 'Template',
          role: 'input',
          sample_id: 7406,
          sample_name: 'pJVLeu-H1-eGFP-H2',
          object_type_name: 'test',
        },
      ],
      outputs: [
        {
          id: 1066390,
          name: 'Fragment',
          role: 'output',
          sample_id: 32817,
          sample_name: 'Fragment_b9390ac7',
          object_type_name: null,
        },
      ],
      data_associations: [
        {
          id: 943064,
          object: '{"status_change":"Status changed to pending on 2020-06-11 by Justin La"}',
        },
        {
          id: 943062,
          object: '{"aborted":"Operation was canceled when job 117487 was aborted"}',
        },
        {
          id: 943059,
          object: '{"no_primer":"You need to order a primer stock for primer sample 32815."}',
        },
        {
          id: 943057,
          object: '{"precondition_warnings":""}',
        },
      ],
    },
    {
      id: 163113,
      operation_id: 289760,
      updated_at: '2020-06-11T04:31:27.000Z',
      status: 'scheduled',
      plan_id: 40034,
      inputs: [
        {
          id: 1066383,
          name: 'Forward Primer',
          role: 'input',
          sample_id: 24555,
          sample_name: 'NanoP_gibInF',
          object_type_name: 'Primer Aliquot',
        },
        {
          id: 1066384,
          name: 'Reverse Primer',
          role: 'input',
          sample_id: 24559,
          sample_name: 'NanoP_YFPgibIn_R',
          object_type_name: 'Primer Aliquot',
        },
        {
          id: 1066385,
          name: 'Template',
          role: 'input',
          sample_id: 24623,
          sample_name: 'Y04_overhang',
          object_type_name: '1 ng/µL Stock',
        },
      ],
      outputs: [
        {
          id: 1066386,
          name: 'Fragment',
          role: 'output',
          sample_id: 34368,
          sample_name: 'Fragment_CS_NORv2_c98ae450',
          object_type_name: null,
        },
      ],
      data_associations: [
        {
          id: 943065,
          object: '{"status_change":"Status changed to pending on 2020-06-11 by Justin La"}',
        },
        {
          id: 943061,
          object: '{"aborted":"Operation was canceled when job 117487 was aborted"}',
        },
        {
          id: 943058,
          object: '{"no_primer":"You need to order a primer stock for primer sample 24555."}',
        },
        {
          id: 943056,
          object: '{"precondition_warnings":""}',
        },
      ],
    },
  ];

  const mockJobId = 117326;
  const mockRemove = jest.fn();
  const mockCancel = jest.fn();

  const tabletWidth = 1280;
  const mockWindowDimensions = {
    height: 976,
    width: 1920,
    tablet: window.innerWidth <= tabletWidth,
  };

  const showJobOperations = () => render(
    <ShowJobOperations
      operations={mockOperations}
      handleCancelJob={mockCancel}
      removeOperation={mockRemove}
      jobId={mockJobId}
    />,
  );

  const showJobOperationsSmall = () => render(
    <WindowDimensionsProvider value={mockWindowDimensions}>
      <ShowJobOperations
        operations={mockOperations}
        handleCancelJob={mockCancel}
        removeOperation={mockRemove}
        jobId={mockJobId}
      />
    </WindowDimensionsProvider>,
  );

  it('should render "no operations" when there are no operations', () => {
    render(
      <WindowDimensionsProvider value={mockWindowDimensions}>
        <ShowJobOperations
          operations={[]}
          handleCancelJob={mockCancel}
          removeOperation={mockRemove}
          jobId={mockJobId}
        />
      </WindowDimensionsProvider>,
    );
    expect(screen.getByText(/no operations/i)).toBeInTheDocument();
  });

  it('should render job operations table', () => {
    showJobOperations();
    expect(screen.queryByRole('table')).toBeInTheDocument();
  });

  it('should render job operations table with column headers header row', () => {
    showJobOperations();
    expect(screen.getAllByRole('columnheader').length).toBeGreaterThan(1);
  });

  it('should render with expected column headers on a large screen', () => {
    showJobOperations();
    expect(screen.getByRole('columnheader', { name: /plan #/i })).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: /input\/output/i })).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: /last updated/i })).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: /client/i })).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: /op id/i })).toBeInTheDocument();
  });

  it('should render with expected column headers on a tablet screen', () => {
    showJobOperationsSmall();
    expect(screen.getByRole('columnheader', { name: /plan #/i })).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: /input\/output/i })).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: /details/i })).toBeInTheDocument();
  });

  it('should render with more than one row when there is at at least one operation', () => {
    showJobOperations();
    expect(screen.getAllByRole('row').length).toBeGreaterThan(1);
  });

  it('should not render the table when there are no operations', () => {
    render(
      <ShowJobOperations
        operations={[]}
        handleCancelJob={mockCancel}
        removeOperation={mockRemove}
        jobId={mockJobId}
      />,
    );
    expect(screen.queryByRole('table')).not.toBeInTheDocument();
  });

  it('should have a remove operation button for each row', () => {
    showJobOperations();
    expect(screen.getAllByRole('button', { name: /remove operation/i }).length).toEqual(3);
  });

  it('should call remove operation function when remove button is clicked clicked', () => {
    showJobOperations();
    const removeBtn = screen.getByRole('button', { name: `remove operation ${mockOperations[0].operation_id}` });
    userEvent.click(removeBtn);
    expect(mockRemove).toHaveBeenCalledTimes(1);
  });

  it('should call remove operation function with the correct id when remove button is clicked clicked', () => {
    showJobOperations();
    const removeBtn = screen.getByRole('button', { name: `remove operation ${mockOperations[1].operation_id}` });
    userEvent.click(removeBtn);
    expect(mockRemove).toHaveBeenCalledWith(mockJobId, mockOperations[1].operation_id);
  });

  it('should call cancel job function when there is only one operation to be removed', () => {
    const mockOps = [mockOperations[0]];
    render(
      <ShowJobOperations
        operations={mockOps}
        handleCancelJob={mockCancel}
        removeOperation={mockRemove}
        jobId={mockJobId}
      />,
    );

    const removeBtn = screen.getByRole('button', { name: `remove operation ${mockOps[0].operation_id}` });
    userEvent.click(removeBtn);
    expect(mockCancel).toHaveBeenCalledTimes(1);
    expect(mockCancel).toHaveBeenCalledWith(mockJobId);
  });

  it('should only show remove button when operation status is "scheduled"', () => {
    const mockOps = mockOperations;
    mockOps[0].status = 'error';
    mockOps[2].status = 'pending';
    mockOps[2].status = 'done';

    render(
      <ShowJobOperations
        operations={mockOps}
        handleCancelJob={mockCancel}
        removeOperation={mockRemove}
        jobId={mockJobId}
      />,
    );

    expect(screen.queryAllByRole('button', { name: 'remove operation' })).toHaveLength(0);
  });
});
