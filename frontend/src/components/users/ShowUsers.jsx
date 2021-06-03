import React from 'react';
import { useHistory } from 'react-router-dom';
// eslint-disable-next-line import/no-extraneous-dependencies
import moment from 'moment';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';

import usersAPI from '../../helpers/api/users';
import globalUseSyles from '../../globalUseStyles';

const useStyles = makeStyles((theme) => ({
  root: {
    height: 'calc(100% - 64px)',
  },

  inventory: {
    fontSize: '0.875rem',
    marginBottom: theme.spacing(2),
  },
}));

// eslint-disable-next-line no-unused-vars, object-curly-newline
const ShowUsers = ({ users, setIsLoading, setAlertProps, permissionsList, currentLetter }) => {
  const classes = useStyles();
  const keyRetired = Object.keys(permissionsList).find((key) => permissionsList[key] === 'retired');
  const history = useHistory();
  const globalClasses = globalUseSyles();

  const toggleRetire = async (user, key, val) => {
    const formData = {
      user_id: user.id,
      permission_id: key,
      value: val,
    };

    const response = await usersAPI.permissionUpdate(formData);
    if (!response) return;

    // success
    if (val === 'on') {
      // eslint-disable-next-line no-param-reassign, operator-assignment, prefer-template
      user.permission_ids = user.permission_ids + `${keyRetired}.`;
    } else {
      // eslint-disable-next-line no-param-reassign
      user.permission_ids = user.permission_ids.replace(`.${keyRetired}.`, '.');
    }
    setAlertProps({
      message: val === 'on' ? 'retired' : 'un-retired',
      severity: 'success',
      open: true,
    });
  };

  return (
    <>
      <div className={globalClasses.flexWrapper}>
        <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
          <Typography className={globalClasses.flexCol1}><b>Name</b></Typography>
          <Typography className={globalClasses.flexCol1}><b>Description</b></Typography>
          <Typography className={globalClasses.flexCol1}><b>Since</b></Typography>
          <Typography className={globalClasses.flexCol1}>Status</Typography>
        </div>

        {users.map((user) => (
          <div className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`object_${user.id}`}>
            <Typography className={globalClasses.flexCol1}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link data-cy={`show_${user.id}`} className={classes.pointer} onClick={() => history.push(`/users/${user.id}/profile`)}>{user.name}</Link>
            </Typography>
            <Typography className={globalClasses.flexCol1}>
              {user.login}
            </Typography>
            <Typography className={globalClasses.flexCol1}>
              {moment(user.created_at).format('DD-MM-YYYY')}
            </Typography>
            <Typography className={globalClasses.flexCol1}>
              {user.permission_ids.indexOf(`.${keyRetired}.`) === -1 ? (
                /* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */
                <Link data-cy={`retire_${user.id}`} className={classes.pointer} onClick={() => toggleRetire(user, keyRetired, 'on')}>retire</Link>
              ) : (
                /* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */
                <Link data-cy={`retire_${user.id}`} className={classes.pointer} onClick={() => toggleRetire(user, keyRetired, 'off')}>un-retire</Link>
              )}
            </Typography>
          </div>
        ))}
      </div>
    </>
  );
};

ShowUsers.propTypes = {
  users: PropTypes.isRequired,
  permissionsList: PropTypes.isRequired,
  currentLetter: PropTypes.isRequired,
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func.isRequired,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default ShowUsers;
