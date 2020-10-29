import React, { useState, } from 'react';
import Button from '@material-ui/core/Button';
import { Redirect, } from "react-router-dom";
import API from '../../helpers/api';

const Logout = (props) => {
  const [ logOutErrors, setLogOutError ] = useState();

  const handleSignOut = (event) => {
    API.sign_out(setLogOutError)
  }

  if (!sessionStorage.getItem("token")) {
    return <Redirect to="/login" />;
  }
  return (
    <Button name="sign_out"
            primary
            type="button"
            onClick={handleSignOut}>
      SIGN OUT
    </Button>
  )
}

export default Logout;