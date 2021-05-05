/* eslint-disable no-alert */
/* eslint-disable no-console */
import axios from 'axios';

const backend = process.env.REACT_APP_BACKEND;
const backendPort = process.env.REACT_APP_BACKEND_PORT;
const backendURL = `http://${backend}:${backendPort}/api/v3`;

axios.defaults.baseURL = backendURL;

// Axios instance we can import and use in our apis
const axiosInstance = axios.create({
  baseURL: backendURL,
});

// For validation we need to send the token with every request to the backend
const currentSessionToken = localStorage.getItem('token');

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

// TODO: Replace javascript with React components
// (need to be able to refer to the parent component here)
axiosInstance.interceptors.response.use(
  (response) => response,
  // eslint-disable-next-line consistent-return
  (error) => {
    const { status, data } = error.response;
    if (status) {
      switch (status) {
        case 400:
          // Show the error message modal
          showError(`${status}: ${data.message}`)
          break;
        case 401:
          // The token is either expired or does not exist
          // In either case put up the modal to re-login
          showModal();
          break;
        case 403:
          // Show the error message modal
          showError(`${status}: ${data.message}`)
          break;
        case 404:
          // Show the error message modal
          showError(`${status}: ${data.message}`)
          break;
        default:
          // Show the error message modal
          showError(`${status}: ${data.message}`)
      }
      return false;
    }
  },
);
export default axiosInstance;
