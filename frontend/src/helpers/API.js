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

// Sample Types
const getTypes = () => (axios
  .get('/sample_types', {
    params: {
      token: currentSessionToken,
    },
  })
  .then((response) => response.data)
  .catch((error) => error)
);

const getTypeById = (id) => (
  axios
    .get(`/sample_types/${id}`, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => response.data.sample_type)
    .catch((error) => error)
);

const sampleTypeCreate = (FormData) => {
  axios
    .post('sample_types/create', {
      sample_type: FormData,
      token: currentSessionToken,
    })
    .then((response) => {
      // TODO: return sucess for notification
      console.log(response);
    })
    .catch((error) => {
      // TODO: return errors for notification
      console.log(error);
    });
};

const API = {
  tokens: {
    isAuthenticated: validateToken,
    signIn,
    signOut,
  },
  samples: {
    getTypes,
    getTypeById,
    create: sampleTypeCreate,
  },
};

export default API;
