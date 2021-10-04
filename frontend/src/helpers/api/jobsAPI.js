import axiosInstance from './axiosInstance';

const jobsAPI = {};

jobsAPI.getCounts = () => axiosInstance
  .get('/jobs/counts')
  .then((response) => response.data)
  .catch((error) => error);

jobsAPI.getUnassigned = () => axiosInstance
  .get('/jobs/unassigned')
  .then((response) => response.data)
  .catch((error) => error);

jobsAPI.getAssigned = () => axiosInstance
  .get('/jobs/assigned')
  .then((response) => response.data)
  .catch((error) => error);

jobsAPI.getFinished = (sevenDays) => axiosInstance
  .get(`/jobs/finished?seven_days=${sevenDays}`)
  .then((response) => response.data)
  .catch((error) => error);

jobsAPI.getJob = (jobId) => axiosInstance
  .get(`/jobs/${jobId}/show`)
  .then((response) => response.data)
  .catch((error) => error);

jobsAPI.getCategoryByStatus = (category, status = 'pending') => axiosInstance
  .get(`/jobs/category/${category}?status=${status}`)
  .then((response) => response.data)
  .catch((error) => error);

jobsAPI.getOperationTypeByCategoryAndStatus = (operationType, category, status = 'pending') => axiosInstance
  .get(`/jobs/category/${category}/${operationType}?status=${status}`)
  .then((response) => response.data)
  .catch((error) => error);

jobsAPI.create = (operationIds) => axiosInstance
  .post('/jobs/create', {
    operation_ids: [...operationIds],
  })
  .then((response) => response.data)
  .catch((error) => error);

jobsAPI.cancelJob = (jobId) => axiosInstance
  .post(`/jobs/${jobId}/delete`)
  .then((response) => response.data)
  .catch((error) => error);

jobsAPI.removeOperation = (jobId, opId) => axiosInstance
  .post(`/jobs/${jobId}/remove/${opId}`)
  .then((response) => response.data)
  .catch((error) => error);

export default jobsAPI;
