import axiosInstance from './axiosInstance';

const itemsAPI = {};

itemsAPI.create = (FormData) => axiosInstance
  .post('/items/create', {
    item: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

export default itemsAPI;
