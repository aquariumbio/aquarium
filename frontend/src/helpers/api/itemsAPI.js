import axiosInstance from './axiosInstance';

const itemsAPI = {};

itemsAPI.getCollectionById = (id) => axiosInstance
  .get(`/items/collection/${id}`)
  .then((response) => response.data)
  .catch((error) => error);

itemsAPI.create = (FormData) => axiosInstance
  .post('/items/create', {
    item: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

itemsAPI.discard = (id) => axiosInstance
  .post(`/items/${id}/discard`)
  .then((response) => response.data)
  .catch((error) => error);

export default itemsAPI;
