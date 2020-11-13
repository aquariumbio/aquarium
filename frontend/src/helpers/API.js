/* eslint-disable no-console */

/* eslint-disable consistent-return */
import axios from 'axios';

axios.defaults.baseURL = 'http://localhost:3001/api/v3/';
const currentSessionToken = sessionStorage.getItem('token');

// TODO: FIX LINTING PROBLEMS & remove disable lines
// eslint-disable-next-line func-names
const validateToken = async function () {
  // eslint-disable-next-line no-return-await
  return await axios
    .post('token/get_user', null, {
      params: {
        token: currentSessionToken,
      },
    })
    .then((response) => {
      const [status, data] = [response.data.status, response.data];

      if (response.data.status === 200) {
        sessionStorage.setItem('token', data.token);
        sessionStorage.setItem('userId', data.id);
        sessionStorage.setItem('permissions', data.permission_ids);
        sessionStorage.setItem('userName', data.login);
        sessionStorage.setItem('name', data.name);
        return true;
      }

      if (status === 200 || (status === 400 && data.error === 'Invalid.')) {
        sessionStorage.clear('token');
        return false;
      }
    });
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
      console.log(response);
      const [status, data] = [response.data.status, response.data.data];

      if (status === 200 && data.token) {
        setLoginError();
        sessionStorage.setItem('token', data.token);
        signInSuccessful = true;
        window.location.reload();
      }

      if (status !== 200) {
        return setLoginError(response.data.error);
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
      const [status, data] = [response.data.status, response.data];

      if (status === 200 || (status === 400 && data.error === 'Invalid.')) {
        sessionStorage.clear('token');
        setLoginOutError();
        window.location.reload();
      }

      if (status !== 200 && !(status === 400 && data.error === 'Invalid.')) {
        return setLoginOutError(data.error);
      }
    });
};

const API = {
  isAuthenticated: validateToken,
  signIn,
  signOut,
};

export default API;
