import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { DataGrid } from '@material-ui/data-grid';
import jobsAPI from '../../helpers/api/jobs';

const columns = [
  {
    field: 'to_name',
    headerName: 'Assigned To',
    flex: 1,
  },
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
    field: 'pc',
    headerName: 'Status',
    valueFormatter: (params) => {
      if (params.value === '-1') { return 'Not Started'; }
      if (params.value === '-2') { return 'Completed'; }
      return 'Running';
    },
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

const ShowAssigned = () => {
  const classes = useStyles();

  const [jobs, setJobs] = useState([]);

  useEffect(() => {
    const init = async () => {
      const response = await jobsAPI.getAssigned();
      if (!response) return;

      // success
      setJobs(response.jobs);
    };

    init();
  }, []);

  return (
    <DataGrid
      columns={columns}
      rows={jobs}
      disableColumnMenu
      disableColumnSelector
      disableSelectionOnClick
      className={classes.root}
      autoHeight
      hideFooter
    />
  );
};

export default ShowAssigned;
