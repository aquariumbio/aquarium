/* eslint-disable consistent-return */
import axios from 'axios';

axios.defaults.baseURL = 'http://localhost:3001/api/v3/';
const sessionToken = sessionStorage.getItem('token');

// TODO: FIX LINTING PROBLEMS & remove disable lines
// eslint-disable-next-line func-names
const validateToken = async function () {
  // eslint-disable-next-line no-return-await
  return await axios
    .post(`token/get_user?token=${sessionToken}`)
    .then((response) => {
      if (response.data.status === 200) {
        return true;
      }
      if (response.data.status !== 200) {
        sessionStorage.clear('token');
        return false;
      }
    });
};

const signIn = async (login, password, setLoginError) => {
  let signInSuccessful = false;
  await axios
    .post(`token/create?login=${login}&password=${password}`)
    .then((response) => {
      if (response.data.status === 200 && response.data.data.token) {
        setLoginError();
        sessionStorage.setItem('token', response.data.data.token);
        signInSuccessful = true;
        window.location.reload();
      }

      if (response.data.status !== 200) {
        return setLoginError(response.data.error);
      }
    });
  return signInSuccessful;
};

const signOut = (setLoginOutError) => {
  axios
    .post(`token/delete?token=${sessionToken}`)
    .then((response) => {
      if (response.data.status === 200) {
        sessionStorage.clear('token');
        setLoginOutError();
        window.location.reload();
      }

      if (response.data.status !== 200) {
        return setLoginOutError(response.data.error);
      }
    });
};

const API = {
  isAuthenticated: validateToken,
  signIn,
  signOut,
};

export default API;
