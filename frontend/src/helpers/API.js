/* eslint-disable no-console */
import axios from 'axios';

axios.defaults.baseURL = 'http://localhost:3001/api/v3';

// For validation we need to send the token with every request to the backend
const currentSessionToken = sessionStorage.getItem('token');

const validateToken = async () => {
  let validToken = false;

  await axios
    .get('/token/get_user', null, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => {
      const [status, data] = [response.status, response.data];

      if (status === 200) {
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
    .post('/token/create', null, {
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
    })
    .catch((error) => {
      setLoginError(error);
      console.log(error);
    });
  return signInSuccessful;
};

const signOut = () => {
  axios
    .post('/token/delete', null, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => {
      const [status] = [response.status, response.data];

      if (status === 200) {
        sessionStorage.clear('token');
        window.location.reload();
      }
    })
    .catch((error) => {
      sessionStorage.clear('token');
      window.location.reload();
      console.log(error);
    });
};

const getTypes = () => (axios
  .get('/sample_types', {
    params: {
      token: currentSessionToken,
    },
  })
  .then((response) => response.data)
  .catch((error) => error)
);

/*
### PERMISSIONS

  get  api/v3/permissions

### USER PERMISSIONS

  GET  api/v3/users/permissions

  POST api/v3/users/permissions/update

### SAMPLE TYPES

  GET  api/v3/sample_types

  POST api/v3/sample_types/create

  GET  api/v3/sample_types/:id

  POST api/v3/sample_types/:id/update

  POST api/v3/sample_types/:id/delete

  const  = async () => {
  await axios
    .post('', null, {
      params: {
        login,
        password,
      },
    })
    .then((response) => {
      const [status, data] = [response.status, response.data];

      if (status === 200) {

      }

      if (status === 401) {

      }
    });
  return ;
};
*/

const API = {
  tokens: {
    isAuthenticated: validateToken,
    signIn,
    signOut,
  },
  samples: {
    getTypes,
  },
};

export default API;
