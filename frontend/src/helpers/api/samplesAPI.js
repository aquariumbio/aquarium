import axiosInstance from './axiosInstance';

// TODO: change this file to sampleTypesAPI.js
// TODO: change current sampleTypesAPI.js to sampleTypesAPI.js
const samplesAPI = {};

// not used
// samplesAPI.getSampleCounts = (list) => axiosInstance
//   .get(`/samples/counts?words=${list}`)
//   .then((response) => response.data)
//   .catch((error) => error);

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

samplesAPI.create = (FormData) => {
  return 'create sample'
}

samplesAPI.update = (id, FormData) => {
  return `edit sample ${id}`
}


// samplesAPI.create = (FormData) => axiosInstance
//   .post('object_types/create', {
//     object_type: FormData,
//   })
//   .then((response) => response.data)
//   .catch((error) => error);
//
// samplesAPI.update = (FormData, id) => axiosInstance
//   .post(`/object_types/${id}/update`, {
//     object_type: FormData,
//   })
//   .then((response) => response.data)
//   .catch((error) => error);
//
// samplesAPI.discard = (id) => axiosInstance
//   .post(`/object_types/${id}/delete`)
//   .then((response) => response.data)
//   .catch((error) => error);

export default samplesAPI;
