import React, { useState, useEffect } from 'react';
import { useHistory } from 'react-router-dom';
import * as queryString from 'query-string';
import PropTypes from 'prop-types';
import Pluralize from 'pluralize';

import { makeStyles } from '@material-ui/core';
import Typography from '@material-ui/core/Typography';
import Link from '@material-ui/core/Link';
import Divider from '@material-ui/core/Divider';
import Breadcrumbs from '@material-ui/core/Breadcrumbs';
import NavigateNextIcon from '@material-ui/icons/NavigateNext';
import Toolbar from '@material-ui/core/Toolbar';
import Grid from '@material-ui/core/Grid';

import SideBar from './SideBar';
import { LinkButton } from '../shared/Buttons';
import wizardsAPI from '../../helpers/api/wizardsAPI';

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

  /* flex */
  flexWrapper: {
    padding: '0 16px',
  },

  flex: {
    display: '-ms-flexbox',
    // eslint-disable-next-line no-dupe-keys
    display: 'flex',
    position: 'relative',
  },

  /* Title row */
  flexTitle: {
    padding: '8px 0',
    borderBottom: '2px solid #ccc',
  },

  /* Data Row */
  flexRow: {
    padding: '8px 0',
    borderBottom: '1px solid #ccc',
    '&:hover': {
      boxShadow: '0 0 3px 0 rgba(0, 0, 0, 0.8)',
    },
  },

  /* Column definiions */
  flexCol1: {
    flex: '1 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol2: {
    flex: '2 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol3: {
    flex: '3 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexCol4: {
    flex: '4 1 0',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  flexColAuto: {
    width: 'auto',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
  },

  /* Use to scale and hide columns in the title row */
  flexColAutoHidden: {
    width: 'auto',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
    visibility: 'hidden',
  },

  show: {
    display: 'block',
  },

  hide: {
    display: 'none',
  },

  pointer: {
    cursor: 'pointer',
  },

  mr8: {
    marginRight: '8px',
  },

  boxElement: {
    float: 'left',
    width: '11.11%',
    lineHeight: '50px',
    textAlign: 'center',
    border: '1px solid #888',
    marginTop: '-1px',
    marginLeft: '-1px',
    fontSize: '10px',
  },

  backgroundGray: {
    color: '#aaa',
    backgroundColor: '#eee',
    fontSize: '20px',
  },

  boxClear: {
    clear: 'both',
  },
}));

const WizardPage = ({ setIsLoading, setAlertProps, match }) => {
  const classes = useStyles();
  const history = useHistory();
  const id = match.params.id;
  const [wizard, setwizard] = useState({});
  const [items, setItems] = useState();
  const [thisBox, setThisBox] = useState();
  const [boxLabel, setBoxLabel] = useState();

  // eslint-disable-next-line arrow-body-style
  const renderRanges = (specification) => {
    var max0 = specification.fields['0'].capacity > 0 ? (specification.fields['0'].capacity - 1) : (<span>&infin;</span>)
    var max1 = specification.fields['1'].capacity > 0 ? (specification.fields['1'].capacity - 1) : (<span>&infin;</span>)
    var max2 = specification.fields['2'].capacity > 0 ? (specification.fields['2'].capacity - 1) : (<span>&infin;</span>)

    return (
      <div>
        {specification.fields['0'].name}.{specification.fields['1'].name}.{specification.fields['2'].name}:
        [0,{max0}].[0,{max1}].[0,{max2}]
      </div>
    );
  };

  useEffect(() => {
    const init = async () => {
      // wrap the API call
      var box = queryString.parse(window.location.search).box;
      const response = await wizardsAPI.getWizardById(id, box);
      if (!response) return;

      // success
      setwizard(response.wizard);
      setItems(response.items);
      setThisBox(response.box);
      setBoxLabel(Pluralize(JSON.parse(response.wizard.specification).fields['1'].name, 2));
    };

    init();
  }, []);

  const getBox = async (box) => {
    // allows user to hit refresh to reload
    history.push(`/wizards/${id}/show?box=${box}`);

    // wrap the API call
    const response = await wizardsAPI.getBox(id, box);
    if (!response) return;

    // success
    setThisBox(response.box);
    setItems(response.items)
  }

  return (
    <>
      <Toolbar className={classes.header}>
        <Breadcrumbs
          separator={<NavigateNextIcon fontSize="small" />}
          aria-label="breadcrumb"
          component="div"
          data-cy="page-title"
        >
          <Typography display="inline" variant="h6" component="h1">
            Wizards
          </Typography>
          <Typography display="inline" variant="h6" component="h1">
            {wizard ? wizard.name : ''}
          </Typography>
        </Breadcrumbs>

        <div>
          <LinkButton
            name="Edit"
            testName="edit_button"
            text="Edit"
            light
            type="button"
            linkTo={`/wizards/${id}/edit`}
          />

          <LinkButton
            name="All Wizards"
            testName="all_wizards_button"
            text="All Wizards"
            light
            type="button"
            linkTo="/wizards"
          />
        </div>
      </Toolbar>

      <Divider />

      <Grid container className={classes.root}>
        {/* SIDE BAR */}
        <SideBar
          setIsLoading={setIsLoading}
          setAlertProps={setAlertProps}
          wizard={wizard}
        />

        {/* MAIN CONTENT */}

        <Grid
          item
          xs={4}
          className={`${classes.root} ${classes.wrapper}`}
        >
          <Typography variant="h5">
            {boxLabel} managed by {wizard ? wizard.name : ''}
          </Typography>

          <p>
            {wizard.specification ? renderRanges(JSON.parse(wizard.specification)) : ''}
          </p>
        <p>
          {wizard.boxes ? (
            <>
            {wizard.boxes.map((box) => (
              <>
                <Link className={`${classes.pointer} ${classes.mr8}`} onClick={() => getBox(box)}>{box}</Link>
                {' '}
              </>
            ))}
            </>
          ) : (
            'loading...'
          )}
        </p>
        </Grid>

        <Grid
          item
          xs={4}
          className={`${classes.root} ${classes.wrapper}`}
        >
          <Typography variant="h5">
            {thisBox}&nbsp;
          </Typography>
          <p>
            {items ? (
              <>
                {items.map((item) => (
                  item.item_id ? (
                    <div className={`${classes.boxElement}`}>
                      <Link className={`${classes.pointer}`} onClick={() => alert(`item ${item.item_id}`)}>{item.item_id}</Link>
                    </div>
                  ) : (
                    <>
                    <div className={`${classes.boxElement} ${classes.backgroundGray}`}>
                      {item.number}
                    </div>
                    </>
                  )
                ))}
              </>
            ) : (
              'loading...'
            )}
            <div className={`${classes.boxClear}`}></div>
          </p>
        </Grid>
      </Grid>
    </>
  );
};

WizardPage.propTypes = {
  setIsLoading: PropTypes.func.isRequired,
  setAlertProps: PropTypes.func,
  match: PropTypes.shape({
    params: PropTypes.objectOf(PropTypes.string),
    path: PropTypes.string,
    url: PropTypes.string,
    isExact: PropTypes.bool,
  }).isRequired,
};

export default WizardPage;
