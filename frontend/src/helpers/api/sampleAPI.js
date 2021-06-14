import axiosInstance from './axiosInstance';

const sampleAPI = {};

// not used
// sampleAPI.getSampleCounts = (list) => axiosInstance
//   .get(`/samples/counts?words=${list}`)
//   .then((response) => response.data)
//   .catch((error) => error);

sampleAPI.getTypes = () => axiosInstance
  .get('/sample_types?list_only=1')
  .then((response) => response.data)
  .catch((error) => error);

sampleAPI.getSamples = (list, sample_type_id, user_id, page) => axiosInstance
  .get(`/samples?words=${list}&sample_type_id=${sample_type_id}&user_id=${user_id}&page=${page}`)
  .then((response) => response.data)
  .catch((error) => error);

sampleAPI.getQuickSearch = (text, sample_type_ids) => axiosInstance
  .get(`/samples/quick_search?text=${text}&sample_type_ids=${sample_type_ids}`)
  .then((response) => response.data)
  .catch((error) => error);

sampleAPI.getById = (id) => axiosInstance
  .get(`/samples/${id}`)
  .then((response) => response.data)
  .catch((error) => error);

// sampleAPI.create = (FormData) => axiosInstance
//   .post('object_types/create', {
//     object_type: FormData,
//   })
//   .then((response) => response.data)
//   .catch((error) => error);
//
// sampleAPI.update = (FormData, id) => axiosInstance
//   .post(`/object_types/${id}/update`, {
//     object_type: FormData,
//   })
//   .then((response) => response.data)
//   .catch((error) => error);
//
// sampleAPI.discard = (id) => axiosInstance
//   .post(`/object_types/${id}/delete`)
//   .then((response) => response.data)
//   .catch((error) => error);

export default sampleAPI;
