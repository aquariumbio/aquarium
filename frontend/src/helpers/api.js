import axios from 'axios'

axios.defaults.baseURL = 'http://localhost:3001/api/v3/';

const API = {
  sign_in: (login, password, setError) => {
    axios.post(`user/sign_in?login=${login}&password=${password}`)
      .then(response => {
        console.log(response)
        if (response.data.status === 200 && response.data.data.token) {
          sessionStorage.setItem('token', response.data.data.token);
          window.location.reload(true);
          return response.data.data.token
        }
        if (response.data.status !== 200) {
          setError(response.data.error);
        }
      });
    /*SIGN OUT SAMPLE RESPONSES
      SUCCESS:
        {
          "status": 200,
          "data": {
              "message": "Success."
          }
        }
      FAIL:
        {
          "status": 400,
          "error": "Invalid."
        }
    */
    },
  sign_out: (setError, all=false) => {
    axios.post(`user/sign_out?token=${sessionStorage.getItem('token')}&all=${all}`)
      .then(response => {
        console.log(response)
        if (response.data.status === 200) {
          sessionStorage.removeItem('token')
          window.location.reload();
        }
  
        if (response.data.status !== 200) {
          return setError(response.data.error)
        }
      })
    /*SIGN OUT SAMPLE RESPONSES
        VALID TOKEN:
          {
            "status": 200,
            "data": {
                "message": "Success."
            }
          }
        INVALID TOKEN:
          {
            "status": 400,
            "error": "Invalid."
          }
    */
  },
  test_token: () => {
    axios.post(`user/validate_token?=${sessionStorage.getItem('token')}`)
        .then(response => {
          console.log(response)
        })
    /*SAMPLE RESPONSE
        VALID TOKEN:
          {
          "status": 200,
          "data": {
              "id": 331,
              "name": "Mariko Anderson",
              "login": "marikoa"
          }
        }
        INVALID INVALID:
          {
            "status": 400,
            "error": "Invalid."
          }
    */
  }
}


export default API