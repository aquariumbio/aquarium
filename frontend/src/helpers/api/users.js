import axiosInstance from '../API';

const usersAPI = {};

usersAPI.getUsers = () => axiosInstance
  .get('/users')
  .then((response) => response.data)
  .catch((error) => error);

usersAPI.getUsersByLetter = (letter) => axiosInstance
  .get(`/users?letter=${letter}`)
  .then((response) => response.data)
  .catch((error) => error);

// usersAPI.getUserById = (id) => axiosInstance
//   .get(`/users/${id}`)
//   .then((response) => response.data)
//   .catch((error) => error);
//
// usersAPI.getUserInfoById = (id) => axiosInstance
//   .get(`/users/${id}/show_info`)
//   .then((response) => response.data)
//   .catch((error) => error);

usersAPI.permissionUpdate = (formData) => axiosInstance
  .post('/users/permissions/update', formData)
  .then((response) => response.data)
  .catch((error) => error);

usersAPI.create = (FormData) => axiosInstance
  .post('/users/create', {
    user: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

usersAPI.getProfile = (id) => axiosInstance
  .get(`/users/${id}/show_info`)
  .then((response) => response.data)
  .catch((error) => error);

usersAPI.updateInfo = (FormData, id) => axiosInstance
  .post(`/users/${id}/update_info`, {
    user: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

usersAPI.updatePreferences = (formData, id) => axiosInstance
  .post(`/users/${id}/preferences`, formData)
  .then((response) => response.data)
  .catch((error) => error);

usersAPI.updateAgreement = (agreement, id) => axiosInstance
  .post(`/users/${id}/agreements/${agreement}`)
  .then((response) => response.data)
  .catch((error) => error);

// usersAPI.delete = (id) => axiosInstance
//   .post(`/users/${id}/delete`)
//   .then((response) => response.data)
//   .catch((error) => error);
//
export default usersAPI;
