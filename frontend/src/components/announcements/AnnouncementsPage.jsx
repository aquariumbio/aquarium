/* eslint-disable */
import React, { forwardRef, useState } from 'react';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import API from '../../helpers/API';
import MenuIcon from '@material-ui/icons/Menu';
import { makeStyles, withStyles } from '@material-ui/core/styles';
import MaterialTable from 'material-table';
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
import Button from '@material-ui/core/Button';
import AddIcon from '@material-ui/icons/Add';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import Grid from '@material-ui/core/Grid';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';
import TextField from '@material-ui/core/TextField';
import axios from 'axios';
import Divider from '@material-ui/core/Divider';
axios.defaults.baseURL = 'http://localhost:3001/api/v3/';

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

const useStyles = makeStyles((theme) => ({
  menuButton: {
    marginRight: theme.spacing(2),
    color: '#00ff22',
    fontSize: '1rem',
  },
  dialog: {
    width: '100%',
  },
  cancelButton: {
    marginLeft: 'auto',
  },
  confirmButton: {
    color: theme.palette.common.white,
    backgroundColor: '#065683',
    '&:hover': {
      backgroundColor: '#065683',
    },
    margin: theme.spacing(1),
  },
  closeIcon: {
    padding: theme.spacing(1),
    marginLeft: theme.spacing(30),
  },
  field: {
    marginTop: theme.spacing(3),
  },
}));

const AnnouncementsPage = () => {
  const classes = useStyles();
  const [show, setShow] = useState(false);
  const [rowData, setRowData] = useState([
    {
      id: 0, title: 'test', message: 'This is a test announcement', active: true,
    },
  ]);
  const [error, setError] = useState(null);
  const [title, setTitle] = useState(null);
  const [message, setMessage] = useState(null);
  const [active, setActive] = useState(null);

  const currentSessionToken = sessionStorage.getItem('token');
   
  const handleGetAnnouncements = async () => {
    var announcementsData = await API.announcements.getAllAnnouncements();
    console.log(announcementsData);
    setRowData((rowData) => [
      ...rowData,
      ...announcementsData
    ])
  }

  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  const handleCreateAnnouncement = () => {
    setRowData((rowData) => [
      ...rowData,
      {
        id: rowData.length + 1, title: title, message: message, active: active,
      },
    ]);
  };

  const handleTitle = (event) => {
    setTitle(event.target.value);
  };

  const handleMessage = (event) => {
    setMessage(event.target.value);
  };

  const handleActive = (event) => {
    setActive(event.target.value);
  };

  const CustomTypography = withStyles(() => ({
    h3: {
      color: '#05486E',
    },
  }))(Typography);

  return (
    <>
      <MenuIcon
        edge="start"
        className={classes.menuButton}
        color="inherit"
        aria-label="menu"
      />
      <Paper elevation={3}>
        <Button
          className={classes.createButton}
          onClick={handleGetAnnouncements}
          variant="contained"
        >
          <AddIcon className={classes.addIcon} />
          Create Announcement
        </Button>
        {show
          ? (
            <Dialog open={show} onClose={handleClose} className={classes.dialog}>
              <form onSubmit={handleGetAnnouncements}>
                <DialogTitle className={classes.title}>
                  <Grid container spacing={20}>
                    <Grid item md={6} xs={12}>
                      <CustomTypography align="left" gutterBottom variant="h3">
                        Create Announement
                      </CustomTypography>
                    </Grid>
                    <Grid item md={6} xs={12}>
                      <IconButton
                        className={classes.closeIcon}
                        onClick={handleClose}
                        aria-label="close"
                      >
                        <CloseIcon />
                      </IconButton>
                    </Grid>
                  </Grid>
                </DialogTitle>
                <DialogContent>
                  <TextField
                    required
                    className={classes.field}
                    fullWidth
                    label="Title"
                    name="Title"
                    onChange={handleTitle}
                    placeholder="Input title"
                    variant="outlined"
                  />
                  <TextField
                    required
                    className={classes.field}
                    fullWidth
                    label="Message"
                    name="Message"
                    onChange={handleMessage}
                    placeholder="Input message"
                    variant="outlined"
                  />
                  <TextField
                    required
                    className={classes.field}
                    fullWidth
                    select
                    SelectProps={{
                      native: true,
                    }}
                    label="Active"
                    onChange={handleActive}
                    placeholder="Select state"
                    variant="outlined"
                  >
                    <option value="true" />
                    <option value="false" />
                  </TextField>
                </DialogContent>
                <Divider />
                <DialogActions>
                  <Button
                    className={classes.cancelButton}
                    onClick={handleClose}
                    variant="contained"
                  >
                    Cancel
            </Button>
                  <Button
                    className={classes.confirmButton}
                    type="submit"
                    variant="contained"
                  >
                    Create
            </Button>
                </DialogActions>
              </form>
            </Dialog>
          ) :
          null}

        <MaterialTable
          icons={tableIcons}
          title="Announcements"
          columns={[
            { title: 'Id', field: 'id' },
            { title: 'Title', field: 'title' },
            { title: 'Message', field: 'message' },
            { title: 'Active', field: 'active' },
          ]}
          data={rowData}
          actions={[
            rowData => ({
              icon: 'delete',
              tooltip: 'Delete User',
              onClick: (event, rowData) => alert('You want to delete ' + rowData.message),
            })
          ]}
          options={{
            actionsColumnIndex: -1
          }}
        />
      </Paper>
    </>
  );
};

export default AnnouncementsPage;
