/* eslint-disable */
import React, { forwardRef, useState, useEffect } from 'react';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import announcementsAPI from '../../helpers/api/announcementsAPI.js';
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
import DialogActions from '@material-ui/core/DialogActions';
import Grid from '@material-ui/core/Grid';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';
import TextField from '@material-ui/core/TextField';
import axios from 'axios';
import Divider from '@material-ui/core/Divider';
import CreateAnnouncementButton from './CreateAnnouncementButton';
import CreateAnnouncementDialog from './CreateAnnouncementDialog';
import AnnouncementsTable from './AnnouncementsTable';
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
    const [rowData, setRowData] = useState([]);
    const [error, setError] = useState(null);
    const [title, setTitle] = useState(null);
    const [message, setMessage] = useState(null);
    const [active, setActive] = useState(null);

    const currentSessionToken = sessionStorage.getItem('token');

    useEffect(() => {
        const handleGetAnnouncements = async () => {
            var announcementsData = await announcementsAPI.getAllAnnouncements();
            setRowData(announcementsData)
        }

        handleGetAnnouncements();
    }, []);


    const handleClose = () => setShow(false);
    const handleShow = () => setShow(true);

    const handleCreateAnnouncement = async () => {
        var response = await announcementsAPI.createAnnouncement(
            {
                "announcement": {
                    "title": title,
                    "message": message,
                    "active": active
                }
            }
        )
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
        console.log(event.target.value)
        setActive(event.target.value);
    };

    const handleDelete = async (event, row) => {
        confirm('You want to delete ' + row.title)
        console.log(rowData.id)
        var announcementsData = await announcementsAPI.deleteAnnouncement(row.id);
        //setRowData(announcementsData)
        setRowData(rowData.filter(item => item.id !== rowData.id));
    }

    

    return (
        <>
            <Paper elevation={3}>
                <CreateAnnouncementButton handleShow={handleShow} />
                {show ?
                    <CreateAnnouncementDialog
                        show={show}
                        handleClose={handleClose}
                        handleCreateAnnouncement={handleCreateAnnouncement}
                        handleTitle={handleTitle}
                        handleMessage={handleMessage}
                        handleActive={handleActive}
                    />
                    :
                    null}

                <AnnouncementsTable
                rowData={rowData}
                setRowData={setRowData}
                />
            </Paper>
        </>
    );
};

export default AnnouncementsPage;
