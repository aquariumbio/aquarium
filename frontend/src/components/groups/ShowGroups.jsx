import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import Link from '@material-ui/core/Link';

import groupsAPI from '../../helpers/api/groupsAPI';
import globalUseSyles from '../../globalUseStyles';

const ShowGroups = ({ groups }) => {
  const globalClasses = globalUseSyles();

  const handleDelete = async (group) => {
    const response = await groupsAPI.delete(group.id);
    if (!response) return;

    // success
    localStorage.alert = JSON.stringify({
      message: 'deleted',
      severity: 'success',
      open: true,
    });

    window.location.reload();
  };

  return (
    <>
        {groups.map((group) => (
          <div className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`object_${group.id}`}>
            <Typography className={globalClasses.flexCol1}>
              <Link data-cy={`show_${group.id}`} component={RouterLink} to={`/groups/${group.id}/show`}>{group.name}</Link>
            </Typography>
            <Typography className={globalClasses.flexCol3}>
              {group.description}
            </Typography>
            <Typography className={globalClasses.flexColAuto}>
              {/* TODO: change to iconButton when available */}
              <Link data-cy={`edit_${group.id}`} component={RouterLink} to={`/groups/${group.id}/edit`}>Edit</Link>
            </Typography>
            <Typography className={globalClasses.flexColAuto}>
              {/* TODO: change to iconButton when available */}
              {/* eslint-disable-next-line jsx-a11y/anchor-is-valid */}
              <Link data-cy={`delete_${group.id}`} className={globalClasses.pointer} onClick={() => handleDelete(group)}>Delete</Link>
            </Typography>
          </div>
        ))}
    </>
  );
};

ShowGroups.propTypes = {
  groups: PropTypes.isRequired,
};

export default ShowGroups;
