import axiosInstance from './axiosInstance';

// TODO: change this file to sampleTypesAPI.js
// TODO: change current sampleTypesAPI.js to sampleTypesAPI.js
const samplesAPI = {};

samplesAPI.getSamples = (list, sample_type_id, user_id, page) => axiosInstance
  .get(`/samples?words=${encodeURIComponent(list)}&sample_type_id=${sample_type_id}&user_id=${user_id}&page=${page}`)
  .then((response) => response.data)
  .catch((error) => error);

samplesAPI.getQuickSearch = (text, sample_type_ids) => axiosInstance
  .get(`/samples/quick_search?text=${encodeURIComponent(text)}&sample_type_ids=${sample_type_ids}`)
  .then((response) => response.data)
  .catch((error) => error);

samplesAPI.getById = (id) => axiosInstance
  .get(`/samples/${id}`)
  .then((response) => response.data)
  .catch((error) => error);

samplesAPI.create = (FormData) => axiosInstance
  .post('samples/create', {
    sample: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

samplesAPI.update = (FormData, id) => axiosInstance
  .post(`/samples/${id}/update`, {
    sample: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

samplesAPI.discard = (id) => axiosInstance
  .post(`/samples/${id}/delete`)
  .then((response) => response.data)
  .catch((error) => error);

export default samplesAPI;
