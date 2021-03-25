/* */
import axios from 'axios';

axios.defaults.baseURL = 'http://localhost:3001/api/v3/';
const currentSessionToken = sessionStorage.getItem('token');

const validateToken = async () => {
  let validToken = false;

  await axios
    .post('token/get_user', null, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => {
      const [status, data] = [response.data.status, response.data];

      if (response.data.status === 200) {
        validToken = true;
      }

      if (status === 400 && data.error === 'Invalid') {
        sessionStorage.clear('token');
      }

      // TODO: HANDLE SESSION TIMEOUT
    });
  return validToken;
};

const signIn = async (login, password, setLoginError) => {
  let signInSuccessful = false;
  await axios
    .post('token/create', null, {
      params: {
        login,
        password,
      },
    })
    .then((response) => {
      const [status, data] = [response.status, response.data];

      if (status === 200 && data.token) {
        setLoginError();
        sessionStorage.setItem('token', data.token);
        signInSuccessful = true;
        window.location.reload();
      }

      if (status === 401) {
        setLoginError(response.data.error);
      }
    });
  return signInSuccessful;
};

const signOut = (setLoginOutError) => {
  axios
    .post('token/delete', null, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => {
      const [status, data] = [response.status, response.data];

      if (status === 200 || (status === 401 && data.error === 'Invalid')) {
        sessionStorage.clear('token');
        setLoginOutError();
        window.location.reload();
      }

      if (status === 401 && data.error !== 'Invalid') {
        setLoginOutError(data.error);
      }
    });
};

// Get Announcements
const getAllAnnouncements = () => (
  axios
    .get('/announcements/', {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => {
      console.log(response.data.announcements);
      return response.data.announcements;
    })
    .catch((error) => {
      console.log(error);
    })
);

const getSpecificAnnouncement = (announcementID) => (
  axios
    .get(`/announcements/${announcementID}`, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => {
      console.log(response.data);
    })
    .catch((error) => {
      console.log(error);
    })
);

// Post Announcements
const createAnnouncement = (FormData) => (
  
  axios
    .post('/announcements/create', FormData, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => response.data)
    .catch((error) => error)
);

// Post Announcements
const updateAnnouncement = (announcementID, FormData) => (
  axios
    .post(`/announcements/${announcementID}/update`, FormData, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => response.data)
    .catch((error) => error)
);

// Delete Announcements

const deleteAnnouncement = (announcementID) => (
  axios
    .post(`/announcements/${announcementID}/delete`, {}, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => response.data)
    .catch((error) => error)
);


const API = {
  tokens: {
    isAuthenticated: validateToken,
    signIn,
    signOut,
  },
  announcements: {
    getAllAnnouncements,
    getSpecificAnnouncement,
    createAnnouncement,
    updateAnnouncement,
    deleteAnnouncement
  },
};

export default API;
