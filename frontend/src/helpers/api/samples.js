import axiosInstance from '../API';

const samplesAPI = {};

samplesAPI.getTypes = () => axiosInstance
  .get('/sample_types')
  .then((response) => response.data)
  .catch((error) => error);

samplesAPI.getTypeById = (id) => axiosInstance
  .get(`/sample_types/${id}`)
  .then((response) => response.data.sample_type)
  .catch((error) => error);

samplesAPI.create = (FormData) => axiosInstance
  .post('sample_types/create', {
    sample_type: FormData,
  })
  .then((response) => response)
  .catch((error) => error);

samplesAPI.update = (FormData, id) => axiosInstance
  .post(`/sample_types/${id}/update`, {
    sample_type: FormData,
  })
  .then((response) => response)
  .catch((error) => error);

samplesAPI.delete = (id) => axiosInstance
  .post(`/sample_types/${id}/delete`)
  .then((response) => response)
  .catch((error) => error);

export default samplesAPI;
