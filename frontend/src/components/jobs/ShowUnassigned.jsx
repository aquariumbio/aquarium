import React, { useState, useEffect } from 'react';

import { DataGrid } from '@material-ui/data-grid';
import { makeStyles } from '@material-ui/core';

import jobsAPI from '../../helpers/api/jobs';

const unassignedColumns = [
  {
    field: 'name',
    headerName: 'Protocol',
    flex: 2,
  },
  {
    field: 'job_id',
    headerName: 'Job',
    flex: 1,
  },
  {
    field: 'operations_count',
    headerName: 'Operations',
    flex: 1,
  },
  {
    field: 'created_at',
    headerName: 'Started',
    sortable: false,
    valueFormatter: (params) => (params.getValue('pc') === '-1' ? '-' : params.getValue('created_at').substring(0, 16).replace('T', ' ')),
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

const ShowUnassigned = () => {
  const classes = useStyles();

  const [jobs, setJobs] = useState([]);

  useEffect(() => {
    const init = async () => {
      const response = await jobsAPI.getUnassigned();
      if (!response) return;

      // success
      setJobs(response.jobs);
    };

    init();
  }, []);

  return (
    <DataGrid
      columns={unassignedColumns}
      rows={jobs}
      className={classes.root}
      disableColumnMenu
      disableColumnSelector
      disableSelectionOnClick
      autoHeight
      hideFooter
    />
  );
};

export default ShowUnassigned;
