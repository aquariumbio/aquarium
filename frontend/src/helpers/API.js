/* eslint-disable no-alert */
/* eslint-disable no-console */
import axios from 'axios';

axios.defaults.baseURL = 'http://localhost:3001/api/v3';

// Axios instance we can import and use in our apis
const axiosInstance = axios.create({
  baseURL: 'http://localhost:3001/api/v3',
});

// For validation we need to send the token with every request to the backend
const currentSessionToken = sessionStorage.getItem('token');

/* We intercept the request to ensure the session token is sent in the params
   on every route except login */
axiosInstance.interceptors.request.use((config) => {
  const newConfig = config;
  if (window.location.pathname !== '/login') {
    newConfig.params = {
      token: currentSessionToken,
      ...newConfig.params,
    };
  }
  return newConfig;
});

// TODO: REPLACE ALL ALERTS WITH PROPER HANDLING
/* Use interceptors to handle error responses generalized by status code
   We can customize the response using the pathname */
axiosInstance.interceptors.response.use(
  (response) => response,
  // eslint-disable-next-line consistent-return
  (error) => {
    const error_response = error.response;
    switch (error_response["status"]) {
      case 400:
        alert("400: "+JSON.stringify(error_response["data"]));
        break;
      case 401:
        if (window.location.pathname !== '/login') {
          if (currentSessionToken) {
            axios.post('/token/delete');
            sessionStorage.clear('token');
          }
        }
        /* TODO: HANDLE SESSION TIMEOUT
           if (...pathname !== '/login' && message !== 'Session timeout') { OPEN LOGIN MODAL} */
        alert("401: "+JSON.stringify(error_response["data"]));
        break;
      case 403:
        // TODO: HANDLE PERMISSIONS
        alert("403: "+JSON.stringify(error_response["data"]));
        break;
      case 404:
        alert("404: "+JSON.stringify(error_response["data"]));
        break;
      default:
        alert(error_response["status"]+": "+JSON.stringify(error_response["data"]));
    }
    // Return something obvious to stop processing. I like simply "false"
    return false;
  },
);
export default axiosInstance;
