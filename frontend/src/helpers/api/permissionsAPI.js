import axiosInstance from './axiosInstance';

const permissionsAPI = {};

permissionsAPI.getPermissions = () => axiosInstance
  .get('/permissions')
  .then((response) => response.data)
  .catch((error) => error);

export default permissionsAPI;
