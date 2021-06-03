import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { DataGrid as MuiDataGrid } from '@material-ui/data-grid';
import PropTypes, { arrayOf, object } from 'prop-types';

/*
const columns = [
  {
    field: 'string', // how it is returned from the api
    headerName: 'string',
    flex: number,
    valueFormatter: (params) => { 'allows for dynamic values'; },
    sortable: bool, // default true
  },
]
*/
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

const DataGrid = ({ columns, rows }) => {
  const classes = useStyles();

  return (
    <MuiDataGrid
      columns={columns}
      rows={rows}
      className={classes.root}
      disableColumnMenu
      disableColumnSelector
      disableSelectionOnClick
      autoHeight
      hideFooter
    />
  );
};

DataGrid.propTypes = {
  columns: arrayOf({ object }).isRequired,
  rows: arrayOf({ object }).isRequired,
};

export default DataGrid;
