/* eslint-disable no-console */
/* eslint-disable react/no-array-index-key */
import React from 'react';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import Grid from '@material-ui/core/Grid';

const useStyles = makeStyles((theme) => ({
  root: {
    margin: theme.spacing(2, 0, 0.5, 0),
  },
  label: {
    fontSize: '0.875rem',
    fontWeight: '700',
    padding: '1px',
  },
  note: {
    fontSize: '0.875rem',
    // fontWeight: '700',
    padding: '1px',
    color: 'rgba(0, 0, 0, 0.5)',
  },
  formControl: {
    margin: theme.spacing(1),
    minWidth: 120,
  },
}));

const FieldLabels = () => {
  const classes = useStyles();
  return (
    // wrap in fragment to maintain grid layout when rendered in parent
    <Grid container spacing={1} className={classes.root} data-cy="field-labels">
      <Grid item lg={2} data-cy="field-name-label-div">
        <Typography variant="h4" className={classes.label}>
          Field Name
        </Typography>
      </Grid>

      <Grid item lg={1} data-cy="field-type-label-div">
        <Typography variant="h4" className={classes.label}>
          Type
        </Typography>
      </Grid>

      <Grid item lg={1} data-cy="field-is-required-label-div">
        <Typography variant="h4" className={classes.label}>
          Required
        </Typography>
      </Grid>

      <Grid item lg={1} data-cy="field-is-array-label-div">
        <Typography variant="h4" className={classes.label}>
          Array
        </Typography>
      </Grid>

      <Grid item lg={2} data-cy="field-sample-options-label-div">
        <Typography variant="h4" className={classes.label}>
          Sample Options
        </Typography>
      </Grid>

      <Grid item lg={4} data-cy="field-choices-label-div">
        <Typography variant="h4" className={classes.label} display="inline">
          Choices
        </Typography>
        <Typography variant="h4" className={classes.note} display="inline">
          (Comma separated. Leave blank for unrestricted value.)
        </Typography>
      </Grid>

      <Grid item lg={1} data-cy="field-choices-label-div" />
    </Grid>
  );
};

export default FieldLabels;
