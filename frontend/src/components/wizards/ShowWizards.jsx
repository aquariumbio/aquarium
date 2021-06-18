import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
import PropTypes from 'prop-types';

import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import Link from '@material-ui/core/Link';
import wizardsAPI from '../../helpers/api/wizardsAPI';
import globalUseSyles from '../../globalUseStyles';
import Page from '../shared/layout/Page';
import Main from '../shared/layout/Main';

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
    sessionStorage.alert = JSON.stringify({
      message: 'deleted',
      severity: 'success',
      open: true,
    });

    window.location.reload();
  };

  const renderRanges = (specification) => {
    var max0 = specification.fields['0'].capacity > 0 ? (specification.fields['0'].capacity - 1) : (<span>&infin;</span>)
    var max1 = specification.fields['1'].capacity > 0 ? (specification.fields['1'].capacity - 1) : (<span>&infin;</span>)
    var max2 = specification.fields['2'].capacity > 0 ? (specification.fields['2'].capacity - 1) : (<span>&infin;</span>)

    return (
      <div>
        [0,{max0}]
        [0,{max1}]
        [0,{max2}]
      </div>
    );
  };

  const renderForm = (specification) => {
    console.log('came here');
    return (
      <div>
        {specification.fields['0'].name}.{specification.fields['1'].name}.{specification.fields['2'].name}
      </div>
    );
  };

  return (
    <Page>
      <Main title={(
        <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
          <Typography className={globalClasses.flexCol1}><b>Name</b></Typography>
          <Typography className={globalClasses.flexCol3}><b>Description</b></Typography>
          <Typography className={globalClasses.flexCol2}><b>Form</b></Typography>
          <Typography className={globalClasses.flexCol1}><b>Ranges</b></Typography>
          <Typography className={globalClasses.flexColAutoHidden}>Edit</Typography>
          <Typography className={globalClasses.flexColAutoHidden}>Delete</Typography>
        </div>
      )}
      >
        {wizards.map((wizard) => (
          <div className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`object_${wizard.id}`}>
            <Typography className={globalClasses.flexCol1}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link data-cy={`show_${wizard.id}`} component={RouterLink} to={`/wizards/${wizard.id}/show`}>{wizard.name}</Link>
            </Typography>

            <Typography className={globalClasses.flexCol3}>
              {wizard.description}
            </Typography>

            <Typography className={globalClasses.flexCol2}>
              {renderForm(JSON.parse(wizard.specification))}
            </Typography>

            <Typography className={globalClasses.flexCol1}>
              {renderRanges(JSON.parse(wizard.specification))}
            </Typography>

            <Typography className={globalClasses.flexColAuto}>
              <Link data-cy={`edit_${wizard.id}`} component={RouterLink} to={`/wizards/${wizard.id}/edit`}>Edit</Link>
            </Typography>

            <Typography className={globalClasses.flexColAuto}>
              {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
              <Link data-cy={`delete_${wizard.id}`} className={globalClasses.pointer} onClick={() => handleDelete(wizard)}>Delete</Link>
            </Typography>
          </div>
        ))}
      </Main>
    </Page>
  );
};

ShowWizards.propTypes = {
  wizards: PropTypes.isRequired,
};

export default ShowWizards;
