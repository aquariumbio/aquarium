import axiosInstance from './axiosInstance';

const sampleTypesAPI = {};

sampleTypesAPI.getTypes = () => axiosInstance
  .get('/sample_types')
  .then((response) => response.data)
  .catch((error) => error);

sampleTypesAPI.getTypeById = (id) => axiosInstance
  .get(`/sample_types/${id}`)
  .then((response) => response.data.sample_type)
  .catch((error) => error);

sampleTypesAPI.create = (FormData) => axiosInstance
  .post('sample_types/create', {
    sample_type: FormData,
  })
  .then((response) => response)
  .catch((error) => error);

sampleTypesAPI.update = (FormData, id) => axiosInstance
  .post(`/sample_types/${id}/update`, {
    sample_type: FormData,
  })
  .then((response) => response)
  .catch((error) => error);

sampleTypesAPI.delete = (id) => axiosInstance
  .post(`/sample_types/${id}/delete`)
  .then((response) => response)
  .catch((error) => error);

export default sampleTypesAPI;
