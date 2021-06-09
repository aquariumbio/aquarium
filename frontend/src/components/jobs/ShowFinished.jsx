import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';

import { DataGrid, GridToolbarContainer } from '@material-ui/data-grid';

import jobsAPI from '../../helpers/api/jobsAPI';

const finishedColumns = [
  {
    headerName: 'Assigned To',
    field: 'to_name',
    flex: 1,
  },
  {
    headerName: 'Assigned',
    field: 'assigned_date',
    valueFormatter: (params) => (params.getValue('assigned_date') ? params.getValue('assigned_date').substring(0, 16).replace('T', ' ') : '-'),
    flex: 1,
  },
  {
    headerName: 'Started',
    field: 'created_at',
    sortable: false,
    valueFormatter: (params) => (params.value.substring(0, 16).replace('T', ' ')),
    flex: 1,
  },
  {
    headerName: 'Finished',
    field: 'updated_at',
    sortable: false,
    valueFormatter: (params) => (params.value.substring(0, 16).replace('T', ' ')),
    flex: 1,
  },
  {
    field: 'name',
    headerName: 'Protocol',
    flex: 2,
  },
  {
    headerName: 'Job',
    field: 'job_id',
    flex: 1,
  },
  {
    headerName: 'Operations',
    field: 'operations_count',
    flex: 1,
  },
];

const useStyles = makeStyles({
  root: {
    minWidth: '1085px',
    fontSize: '12px',

    '& .MuiDataGrid-colCellTitle': {
      fontWeight: 700,
    },
    '& .cellValue': {
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
    },
    '& .MuiDataGrid-root': {
      border: 'none',
    },
  },
});

// eslint-disable-next-line no-unused-vars
const ShowFinished = ({ setList, setIsLoading, setAlertProps }) => {
  const classes = useStyles();

  const [jobs, setJobs] = useState([]);
  const [sevenDays, setSevenDays] = useState('0');

  const init = async (val) => {
    // wrap the API call
    const response = await jobsAPI.getFinished(val);
    if (!response) return;

    // success
    setJobs(response.jobs);
    setSevenDays(val);
  };

  useEffect(() => {
    init('0');
  }, []);

  const CustomToolbar = () => (
    <GridToolbarContainer>
      <TextField
        name="seven-days"
        id="seven-days-input"
        value={sevenDays}
        onChange={(event) => init(event.target.value)}
        variant="outlined"
        type="string"
        inputProps={{
          'aria-label': 'seven-days-input',
          'data-cy': 'seven-days-input',
        }}
        select
      >
        <MenuItem key="1" value="1">Last 7 Days</MenuItem>
        <MenuItem key="0" value="0">All</MenuItem>
      </TextField>
    </GridToolbarContainer>
  );

  return (
    <DataGrid
      columns={finishedColumns}
      rows={jobs}
      className={classes.root}
      disableColumnMenu
      disableColumnSelector
      disableSelectionOnClick
      autoHeight
      hideFooter
      components={{
        Toolbar: CustomToolbar,
      }}
    />
  );
};

ShowFinished.propTypes = {
  setList: PropTypes.func,
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
};

export default ShowFinished;
