import axios from 'axios';
import { Redirect } from "react-router-dom";

axios.defaults.baseURL = 'http://localhost:3001/api/v3/';
const session_token = sessionStorage.getItem('token');

const validate_token = function() {
  axios
    .post(`user/validate_token?token=${session_token}`)
    .then(response => {
      // when the token is invalid we redirect the user to the login page
      if (response.data.status !== 200) {
        console.log(response.data.error)
        sessionStorage.clear('token');
        return <Redirect to="/login" />;
      }
    })
};

const sign_out = (setLoginOutError) => {
  axios
    .post(`user/sign_out?token=${session_token}`)
    .then(response => {
      if (response.data.status === 200) {
        sessionStorage.clear('token');
        window.location.reload();
        return <Redirect to="/login" />;
      }

      if (response.data.status !== 200) {
        return setLoginOutError(response.data.error)
      }
    })
};

const API = { 
  validate_token: validate_token,
  sign_out: sign_out, 
};

export default API 