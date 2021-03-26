/* eslint-disable */
import React, { forwardRef, useState } from 'react';
import announcementsAPI from '../../helpers/api/announcementsAPI';
import { createMuiTheme, MuiThemeProvider } from '@material-ui/core/styles';
import MaterialTable, { MTableBodyRow } from 'material-table';
import AddBox from '@material-ui/icons/AddBox';
import ArrowDownward from '@material-ui/icons/ArrowDownward';
import Check from '@material-ui/icons/Check';
import ChevronLeft from '@material-ui/icons/ChevronLeft';
import ChevronRight from '@material-ui/icons/ChevronRight';
import Clear from '@material-ui/icons/Clear';
import DeleteOutline from '@material-ui/icons/DeleteOutline';
import Edit from '@material-ui/icons/Edit';
import FilterList from '@material-ui/icons/FilterList';
import FirstPage from '@material-ui/icons/FirstPage';
import LastPage from '@material-ui/icons/LastPage';
import Remove from '@material-ui/icons/Remove';
import SaveAlt from '@material-ui/icons/SaveAlt';
import Search from '@material-ui/icons/Search';
import ViewColumn from '@material-ui/icons/ViewColumn';
import PropTypes from 'prop-types';

const tableIcons = {
  Add: forwardRef((props, ref) => <AddBox {...props} ref={ref} />),
  Check: forwardRef((props, ref) => <Check {...props} ref={ref} />),
  Clear: forwardRef((props, ref) => <Clear {...props} ref={ref} />),
  Delete: forwardRef((props, ref) => <DeleteOutline {...props} ref={ref} />),
  DetailPanel: forwardRef((props, ref) => <ChevronRight {...props} ref={ref} />),
  Edit: forwardRef((props, ref) => <Edit {...props} ref={ref} />),
  Export: forwardRef((props, ref) => <SaveAlt {...props} ref={ref} />),
  Filter: forwardRef((props, ref) => <FilterList {...props} ref={ref} />),
  FirstPage: forwardRef((props, ref) => <FirstPage {...props} ref={ref} />),
  LastPage: forwardRef((props, ref) => <LastPage {...props} ref={ref} />),
  NextPage: forwardRef((props, ref) => <ChevronRight {...props} ref={ref} />),
  PreviousPage: forwardRef((props, ref) => <ChevronLeft {...props} ref={ref} />),
  ResetSearch: forwardRef((props, ref) => <Clear {...props} ref={ref} />),
  Search: forwardRef((props, ref) => <Search {...props} ref={ref} />),
  SortArrow: forwardRef((props, ref) => <ArrowDownward {...props} ref={ref} />),
  ThirdStateCheck: forwardRef((props, ref) => <Remove {...props} ref={ref} />),
  ViewColumn: forwardRef((props, ref) => <ViewColumn {...props} ref={ref} />),
};

const AnnouncementsTable = ({ rowData, setRowData }) => {
  const theme = createMuiTheme({
    palette: {
      primary: {
        main: '#136390',
      },
      secondary: {
        main: '#136390',
      },
    },
    overrides: {
      MuiTableRow: {
        root: {
          "&:hover": {
            backgroundColor: '#d2f8d2'
          }
        }
      }
    }
  });

  return (
    <MuiThemeProvider theme={theme}>
      <MaterialTable
        icons={tableIcons}
        title="Announcements"
        columns={[
          { title: 'Id', field: 'id', editable: 'never' },
          { title: 'Title', field: 'title' },
          { title: 'Message', field: 'message' },
          { title: 'Active', field: 'active', type: 'boolean', render: rowData => (rowData.active ? "true" : "false"), },
        ]}
        data={rowData}
        options={{
          actionsColumnIndex: -1,
          paging: true,
          pageSize: 10,       // make initial page size
          emptyRowsWhenPaging: true,   //to make page size fix in case of less data rows
          headerStyle: { position: 'sticky', top: 0 },
          maxBodyHeight: '80vh',
          minBodyHeight: '80vh',
          rowStyle: {
            height: '5rem',
          }
        }}
        localization={{ body: { editRow: { deleteText: 'Are you sure you want to delete this announcement?' } } }}
        editable={{
          onRowUpdate: (newData, oldData) =>
            new Promise((resolve, reject) => {
              setTimeout(async () => {
                const response = await announcementsAPI.updateAnnouncement(oldData.id, newData);
                if (response.announcement !== null) {
                  const dataUpdate = [...rowData];
                  const index = oldData.tableData.id;
                  dataUpdate[index] = newData;
                  setRowData([...dataUpdate]);
                } else {
                  alert("There was an error updating Announcement #" + oldData.id + " " + oldData.title)
                }
                resolve();
              }, 1000)

            }),
          onRowDelete: oldData =>
            new Promise((resolve, reject) => {

              setTimeout(async () => {
                const response = await announcementsAPI.deleteAnnouncement(oldData.id);
                if (response.message == "Announcement deleted") {
                  const dataDelete = [...rowData];
                  const index = oldData.tableData.id;
                  dataDelete.splice(index, 1);
                  setRowData([...dataDelete]);
                } else {
                  alert("There was an error deleting Announcement #" + oldData.id + " " + oldData.title)
                }
                resolve()
              }, 1000)
            }),
        }}
      />
    </MuiThemeProvider>
  );
};

AnnouncementsTable.propTypes = {
  rowData: PropTypes.arrayOf(PropTypes.shape({
    title: PropTypes.string,
    message: PropTypes.string,
    active: PropTypes.bool
  })).isRequired,
  setRowData: PropTypes.func.isRequired,
};
export default AnnouncementsTable;
