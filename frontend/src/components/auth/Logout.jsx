import React, { useState, useEffect, } from 'react';
import Button from '@material-ui/core/Button';
import { useHistory, Redirect, } from "react-router-dom";
import axios from "axios";

export default function Logout(props) {
  let history = useHistory();

  const [ logOutErrors, setLoginOutError ] = useState();
  const [ logout, setlogout ] = useState(false);

  useEffect(() => {
    if (logout && !logOutErrors !== "") {
      // storetoken in local storage to keep user logged in between page refreshes
      localStorage.clear('token');
    }
  });

  const handleSignOut = (event) => {
    const token = localStorage.getItem('token');

    axios
    .post(`user/sign_out?token=${token}`)
    .then(response => {
      if (response.data.status === 200) {
        setlogout(true);
        history.push("/login");
        window.location.reload();
      }

      if (response.data.status !== 200) {
        return setLoginOutError(response.data.error)
      }
    })
  }
  if (!localStorage.getItem("token")) {
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
