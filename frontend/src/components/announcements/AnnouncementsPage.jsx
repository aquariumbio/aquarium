/* eslint-disable */
import React, { useState, useEffect } from 'react';
import Paper from '@material-ui/core/Paper';
import announcementsAPI from '../../helpers/api/announcementsAPI';
import { makeStyles } from '@material-ui/core/styles';
import {
  Grid,
} from '@material-ui/core';
import CreateAnnouncementDialog from './CreateAnnouncementDialog';
import AnnouncementsTable from './AnnouncementsTable';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100%'
  },
  paper: {
    minHeight: '90vh'
  },
  dialogGrid: {
    position: 'sticky',
    height: '100%',
    left: theme.spacing(0),
    top: theme.spacing(0)
  },
  table: {
    height: '100%'
  }
}));

const AnnouncementsPage = () => {
  const classes = useStyles();
  const [rowData, setRowData] = useState([]);
  const [title, setTitle] = useState(null);
  const [message, setMessage] = useState(null);
  const [active, setActive] = useState(false);

  useEffect(() => {
    const handleGetAnnouncements = async () => {
      var announcementsData = await announcementsAPI.getAllAnnouncements();
      setRowData(announcementsData)
    }

    handleGetAnnouncements();
  }, []);

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
    setActive(event.target.checked);
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
      <Paper elevation={3} className={classes.paper}>
        <Grid
          container
          direction="row">
          <Grid item xs={3} sm={3} className={classes.dialogGrid}>
            <CreateAnnouncementDialog
              handleCreateAnnouncement={handleCreateAnnouncement}
              handleTitle={handleTitle}
              handleMessage={handleMessage}
              handleActive={handleActive}
              active={active}
            />
          </Grid>
          <Grid item xs={12} sm={9} className={classes.table}>
            <AnnouncementsTable
              rowData={rowData}
              setRowData={setRowData}
            />
          </Grid>
        </Grid>
      </Paper>
    </>
  );
};

export default AnnouncementsPage;
