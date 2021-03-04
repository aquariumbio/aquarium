import axiosInstance from './axiosInstance';

const wizardsAPI = {};

wizardsAPI.getWizards = () => axiosInstance
  .get('/wizards')
  .then((response) => response.data)
  .catch((error) => error);

wizardsAPI.getWizardsByLetter = (letter) => axiosInstance
  .get(`/wizards?letter=${letter}`)
  .then((response) => response.data)
  .catch((error) => error);

wizardsAPI.getWizardById = (id) => axiosInstance
  .get(`/wizards/${id}`)
  .then((response) => response.data)
  .catch((error) => error);

wizardsAPI.create = (FormData) => axiosInstance
  .post('/wizards/create', {
    wizard: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

wizardsAPI.update = (FormData, id) => axiosInstance
  .post(`/wizards/${id}/update`, {
    wizard: FormData,
  })
  .then((response) => response.data)
  .catch((error) => error);

wizardsAPI.delete = (id) => axiosInstance
  .post(`/wizards/${id}/delete`)
  .then((response) => response.data)
  .catch((error) => error);

export default wizardsAPI;
