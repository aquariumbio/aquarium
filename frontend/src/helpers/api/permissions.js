import axiosInstance from '../API';

const permissionsAPI = {};

permissionsAPI.getPermissions = () => axiosInstance
  .get('/permissions')
  .then((response) => response.data)
  .catch((error) => error);

export default permissionsAPI;
