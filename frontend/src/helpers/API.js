/* eslint-disable consistent-return */
import axios from 'axios';

axios.defaults.baseURL = 'http://localhost:3001/api/v3/';
const sessionToken = sessionStorage.getItem('token');

// TODO: FIX LINTING PROBLEMS & remove disble lines
// eslint-disable-next-line func-names
const validateToken = async function () {
  // eslint-disable-next-line no-return-await
  return await axios
    .post(`user/validate_token?token=${sessionToken}`)
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

const signOut = (setLoginOutError) => {
  axios
    .post(`user/sign_out?token=${sessionToken}`)
    .then((response) => {
      if (response.data.status === 200) {
        sessionStorage.clear('token');
        window.location.reload();
      }

      if (response.data.status !== 200) {
        return setLoginOutError(response.data.error);
      }
    });
};

const API = {
  isAuthenticated: validateToken,
  sign_out: signOut,
};

export default API;
