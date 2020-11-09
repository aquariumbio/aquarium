import React, { useState, useEffect } from 'react';
import Button from '@material-ui/core/Button';
import { useHistory, Redirect } from 'react-router-dom';
import axios from 'axios';

export default function LogoutButton() {
  const history = useHistory();

  const [logOutErrors, setLoginOutError] = useState();
  const [logout, setlogout] = useState(false);

  useEffect(() => {
    if (logout && !logOutErrors !== '') {
      // storetoken in session storage to keep user logged in between page refreshes
      sessionStorage.clear('token');
    }
  });

  const handleSignOut = () => {
    const token = sessionStorage.getItem('token');

    axios
      .post(`token/delete?token=${token}`)
      // eslint-disable-next-line consistent-return
      .then((response) => {
        if (response.data.status === 200) {
          setlogout(true);
          history.push('/login');
          window.location.reload();
        }

        if (response.data.status !== 200) {
          return setLoginOutError(response.data.error);
        }
      });
  };
  if (!sessionStorage.getItem('token')) {
    return <Redirect to="/login" />;
  }
  return (
    <Button
      name="sign_out"
      primary
      type="button"
      onClick={handleSignOut}
    >
      SIGN OUT
    </Button>
  );
}
