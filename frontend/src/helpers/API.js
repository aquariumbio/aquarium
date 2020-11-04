import axios from 'axios';

axios.defaults.baseURL = 'http://localhost:3001/api/v3/';
const session_token = sessionStorage.getItem('token');

const validate_token = async function() {
  return await axios
    .post(`user/validate_token?token=${session_token}`)
    .then(response => {
      if (response.data.status === 200) {
        return true
      }
      if (response.data.status !== 200) {
        sessionStorage.clear('token');
        return false;
      }
    });
};

const sign_out = (setLoginOutError) => {
  axios
    .post(`user/sign_out?token=${session_token}`)
    .then(response => {
      if (response.data.status === 200) {
        sessionStorage.clear('token');
        window.location.reload();
      }

      if (response.data.status !== 200) {
        return setLoginOutError(response.data.error)
      }
    })
};

const API = { 
  isAuthenticated: validate_token,
  sign_out: sign_out, 
};

export default API 