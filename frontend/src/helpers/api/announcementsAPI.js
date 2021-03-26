import axiosInstance from './axiosInstance';

const announcementsAPI = {};

// Get Announcements
announcementsAPI.getAllAnnouncements = () => axiosInstance
  .get('/announcements/')
  .then((response) => response.data.announcements)
  .catch((error) => error);

announcementsAPI.getSpecificAnnouncement = (announcementID) => axiosInstance
  .get(`/announcements/${announcementID}`)
  .then((response) => response.data)
  .catch((error) => error);

// Post Announcements
announcementsAPI.createAnnouncement = (FormData) => axiosInstance
  .post('/announcements/create', FormData)
  .then((response) => response.data)
  .catch((error) => error);

// Update Announcements
announcementsAPI.updateAnnouncement = (announcementID, FormData) => axiosInstance
  .post(`/announcements/${announcementID}/update`, FormData)
  .then((response) => response.data)
  .catch((error) => error);

// Delete Announcements
announcementsAPI.deleteAnnouncement = (announcementID) => axiosInstance
  .post(`/announcements/${announcementID}/delete`, {})
  .then((response) => response.data)
  .catch((error) => error);

export default announcementsAPI;
