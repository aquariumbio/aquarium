import axiosInstance from './axiosInstance';

const groupsAPI = {};

groupsAPI.getGroups = () => axiosInstance
  .get('/groups')
  .then((response) => response.data)
  .catch((error) => error);

groupsAPI.getGroupsByLetter = (letter) => axiosInstance
  .get(`/groups?letter=${letter}`)
  .then((response) => response.data)
  .catch((error) => error);

groupsAPI.getGroupById = (id) => axiosInstance
  .get(`/groups/${id}`)
  .then((response) => response.data)
  .catch((error) => error);

groupsAPI.create = (FormData) => axiosInstance
  .post('/groups/create', {
    group: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

groupsAPI.update = (FormData, id) => axiosInstance
  .post(`/groups/${id}/update`, {
    group: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

groupsAPI.delete = (id) => axiosInstance
  .post(`/groups/${id}/delete`)
  .then((response) => response.data)
  .catch((error) => error);

export default groupsAPI;
