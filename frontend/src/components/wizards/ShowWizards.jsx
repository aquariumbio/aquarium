import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';
import wizardsAPI from '../../helpers/api/wizards';
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

const ShowWizards = ({ wizards }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();

  const handleDelete = async (wizard) => {
    const response = await wizardsAPI.delete(wizard.id);
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
      <div className={globalClasses.flexWrapper}>
        <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
          <Typography className={globalClasses.flexCol1}><b>Name</b></Typography>
          <Typography className={globalClasses.flexCol3}><b>Description</b></Typography>
          <Typography className={globalClasses.flexColAutoHidden}>Edit</Typography>
          <Typography className={globalClasses.flexColAutoHidden}>Delete</Typography>
        </div>

        {wizards.map((wizard) => (
          <div className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`object_${wizard.id}`}>
            <Typography className={globalClasses.flexCol1}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link data-cy={`show_${wizard.id}`} className={classes.pointer} onClick={() => alert('wizard page')}>{wizard.name}</Link>
            </Typography>

            <Typography className={globalClasses.flexCol3}>
              {wizard.description}
            </Typography>

            <Typography className={globalClasses.flexColAuto}>
              <Link data-cy={`edit_${wizard.id}`} component={RouterLink} to={`/wizards/${wizard.id}/edit`}>Edit</Link>
            </Typography>

            <Typography className={globalClasses.flexColAuto}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link data-cy={`delete_${wizard.id}`} className={classes.pointer} onClick={() => handleDelete(wizard)}>Delete</Link>
            </Typography>
          </div>
        ))}
      </div>
    </>
  );
};

ShowWizards.propTypes = {
  wizards: PropTypes.isRequired,
};

export default ShowWizards;
