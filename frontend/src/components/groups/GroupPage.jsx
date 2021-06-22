import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import Grid from '@material-ui/core/Grid';
import Link from '@material-ui/core/Link';

import SideBarContent from './SideBar';
import { LinkButton } from '../shared/Buttons';
import groupsAPI from '../../helpers/api/groupsAPI';
import Page from '../shared/layout/Page';
import Main from '../shared/layout/Main';
import SideBar from '../shared/layout/SideBar';
import globalUseSyles from '../../globalUseStyles';

// Route: /object_types
// Linked in LeftHamburgeMenu

const useStyles = makeStyles((theme) => ({
  root: {
    height: '100vh',
  },

  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  wrapper: {
    padding: '0 24px',
  },

  letter: {
    color: theme.palette.primary.main,
  },

}));

const GroupPage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();

  const [groupMembers, setGroupMembers] = useState([]);
  const [groupName, setGroupName] = useState('');
  const id = match.params.id;

  const init = async () => {
    // wrap the API call
    const response = await groupsAPI.getGroupById(id);
    if (!response) return;

    // success
    setGroupName(response.group.name);
    setGroupMembers(response.members);
  };

  // initialize to all and get permissions
  useEffect(() => {
    init();
  }, []);

  const handleRemove = async (userId) => {
    // wrap the API call
    const response = await groupsAPI.removeMember(id, userId);
    if (!response) return;

    // success
    init();
  };

  return (
    <Page>
      <SideBar>
        <SideBarContent
          setIsLoading={setIsLoading}
          setAlertProps={setAlertProps}
          id={id}
          refresh={init}
        />
      </SideBar>
      <Main title={(
        <Toolbar className={classes.header}>
          <Breadcrumbs
            separator={<NavigateNextIcon fontSize="small" />}
            aria-label="breadcrumb"
            component="div"
            data-cy="page-title"
          >
            <Typography display="inline" variant="h6" component="h1">
              Groups
            </Typography>
            <Typography display="inline" variant="h6" component="h1">
              {groupName}
            </Typography>
          </Breadcrumbs>

          <div>
            <LinkButton
              name="All Groups"
              testName="all_groups_button"
              text="All Groups"
              light
              type="button"
              linkTo="/groups"
            />
          </div>
        </Toolbar>
      )}
      >
        <div className={globalClasses.flexWrapper}>
          <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
            <Typography className={globalClasses.flexCol1}><b>Name</b></Typography>
            <Typography className={globalClasses.flexCol1}><b>Login</b></Typography>
            <Typography className={globalClasses.flexColAutoHidden}>Remove</Typography>
          </div>

          {groupMembers ? (
            groupMembers.map((member) => (
              <div className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`member_${member.id}`}>
                <Typography className={globalClasses.flexCol1}>
                  {member.name}
                </Typography>
                <Typography className={globalClasses.flexCol1}>
                  {member.login}
                </Typography>
                <Typography className={globalClasses.flexColAuto}>
                  {/* eslint-disable-next-line max-len, jsx-a11y/anchor-is-valid */}
                  <Link data-cy={`remove_${member.id}`} className={globalClasses.pointer} onClick={() => handleRemove(member.id)}>Remove</Link>
                </Typography>
              </div>
            ))
          ) : (
            ''
          )}
        </div>
      </Main>
    </Page>
  );
};

GroupPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default GroupPage;
