import axiosInstance from './axiosInstance';

const objectsAPI = {};

objectsAPI.getHandlers = () => axiosInstance
  .get('/object_types')
  .then((response) => response.data)
  .catch((error) => error);

objectsAPI.getByHandler = (handler) => axiosInstance
  .get(`/object_types/handler/${handler}`)
  .then((response) => response.data)
  .catch((error) => error);

objectsAPI.getBySample = (id) => axiosInstance
  .get(`/object_types/sample/${id}`)
  .then((response) => response.data)
  .catch((error) => error);

objectsAPI.getById = (id) => axiosInstance
  .get(`/object_types/${id}`)
  .then((response) => response.data)
  .catch((error) => error);

objectsAPI.create = (FormData) => axiosInstance
  .post('object_types/create', {
    object_type: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

objectsAPI.update = (FormData, id) => axiosInstance
  .post(`/object_types/${id}/update`, {
    object_type: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

objectsAPI.delete = (id) => axiosInstance
  .post(`/object_types/${id}/delete`)
  .then((response) => response.data)
  .catch((error) => error);

export default objectsAPI;
