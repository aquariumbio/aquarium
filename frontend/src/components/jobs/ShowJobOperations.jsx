import React from 'react';
import {
  array,
  func,
  number,
} from 'prop-types';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import IconButton from '@material-ui/core/IconButton';
import RemoveCircleOutlineIcon from '@material-ui/icons/RemoveCircleOutline';
import Paper from '@material-ui/core/Paper';
import Grid from '@material-ui/core/Grid';
import globalUseSyles from '../../globalUseStyles';
import { useWindowDimensions } from '../../WindowDimensionsProvider';

const useStyles = makeStyles((theme) => ({
  title: {
    padding: `${theme.spacing(2)}px ${theme.spacing(4)}px`,
    borderBottom: '1px solid #DDD',
    fontWeight: 'bold',

    '& p': {
      fontWeight: 'bold',
      lineHeight: 1.75,
    },
  },
  paper: {
    overflow: 'hidden',
    display: 'flex',
    flexDirection: 'column',
  },
  titleArea: {
    [theme.breakpoints.down('lg')]: {
      paddingRight: 0,
    },
  },
  border: {
    borderTopWidth: '1px',
  },
}));

const ShowJobOperations = ({
  operations,
  removeOperation,
  handleCancelJob,
  jobId,
}) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();
  const tablet = useWindowDimensions();

  const handleRemove = (opId) => {
    removeOperation(jobId, opId);
  };

  if (!operations || operations.length === 0) {
    return <div> No operations</div>;
  }

  const title = (
    <div
      className={`${classes.border} ${globalClasses.flex} ${classes.title}`}
      key="title"
      role="row"
    >
      <div className={`${globalClasses.flexCol1}`} />
      <div role="columnheader" className={`${globalClasses.flexCol1}`}>
        <Typography variant="body2">Plan #</Typography>
      </div>
      <div role="columnheader" className={`${globalClasses.flexCol4}`}>
        <Typography variant="body2">Input/Output</Typography>
      </div>
      {tablet ? (
        <div role="columnheader" className={`${globalClasses.flexCol2}`}>
          <Typography variant="body2">Details</Typography>
        </div>
      ) : (
        <>
          <div role="columnheader" className={`${globalClasses.flexCol2}`}>
            <Typography variant="body2">Last Updated</Typography>
          </div>
          <div role="columnheader" className={`${globalClasses.flexCol2}`}>
            <Typography variant="body2">Client</Typography>
          </div>
          <div role="columnheader" className={`${globalClasses.flexCol1}`}>
            <Typography variant="body2">Op ID</Typography>
          </div>
        </>
      )}
    </div>
  );
  const displayInOutData = (operation) => (
    // TODO: how many data rows to show?
    <>
      {!!operation.inputs && operation.inputs.map((input, index) => (
        // eslint-disable-next-line react/no-array-index-key
        <div className={`${globalClasses.flex} ${globalClasses.flexRowNested}`} key={index}>
          <div className={globalClasses.flexCol1}>
            <Typography variant="body2" noWrap>{index === 0 ? 'in:' : ''}</Typography>
          </div>
          <div className={globalClasses.flexCol2}>
            <Typography variant="body2" noWrap>{input.name}</Typography>
          </div>
          {input.sample_id && input.sample_name ? (
            <div className={globalClasses.flexCol4}>
              <Typography variant="body2" noWrap>{input.sample_id}: {input.sample_name}</Typography>
            </div>
          ) : <div className={globalClasses.flexCol4} />}
        </div>
      ))}

      {!!operation.outputs && operation.outputs.map((output, index) => (
        // eslint-disable-next-line react/no-array-index-key
        <div className={`${globalClasses.flex}`} key={index}>
          <div className={globalClasses.flexCol1}>
            <Typography variant="body2">{index === 0 ? 'out:' : ''}</Typography>
          </div>
          <div className={globalClasses.flexCol2}>
            <Typography variant="body2" noWrap>{output.name}</Typography>
          </div>
          {output.sample_id && output.sample_name ? (
            <div className={globalClasses.flexCol4}>
              <Typography variant="body2" noWrap>{output.sample_id}: {output.sample_name}</Typography>
            </div>
          ) : <div className={globalClasses.flexCol4} />}
        </div>
      ))}

      {!!operation.data_associations && operation.data_associations.map((da, index) => {
        const data = JSON.parse(da.object);
        const key = Object.keys(data)[0];
        const value = data[key];
        // if no associated text skip row
        if (value === '') {
          return false;
        }
        return (
          // eslint-disable-next-line react/no-array-index-key
          <div className={`${globalClasses.flex}`} key={index}>
            <div className={globalClasses.flexCol1} />
            <div className={globalClasses.flexCol2}>
              <Typography variant="body2" noWrap>{key.replace('_', ' ')}:</Typography>
            </div>
            <div className={globalClasses.flexCol4}>
              <Typography variant="body2" noWrap>{value}</Typography>
            </div>
          </div>
        );
      })}
    </>
  );

  const rows = (
    operations.map((operation) => (
      <div role="row" className={`${globalClasses.flex} ${globalClasses.flexRow}`} key={`op_${operation.id}`}>
        <div role="cell" className={`${globalClasses.flexCol1}`}>
          {operation.status === 'scheduled' && (
            <IconButton
              aria-label={`remove operation ${operation.operation_id}`}
              onClick={() => {
                operations.length > 1
                  ? handleRemove(operation.operation_id)
                  : handleCancelJob(jobId);
              }}
            >
              <RemoveCircleOutlineIcon htmlColor="#FF0000" />
            </IconButton>
          )}
        </div>
        <div role="cell" className={`${globalClasses.flexCol1}`}>
          <Typography variant="body2" noWrap>{operation.plan_id}</Typography>
        </div>
        <div role="cell" className={`${globalClasses.flexCol4}`}>
          {displayInOutData(operation)}
        </div>
        {tablet ? (
          <div className={`${globalClasses.flexCol2}`}>
            <Typography variant="body2" noWrap>Updated: {operation.updated_at.substring(0, 16).replace('T', ' ')}</Typography>
            <Typography variant="body2" noWrap>Researcher: {operation.user_name}</Typography>
            <Typography variant="body2" noWrap>Op Id: {operation.id}</Typography>
          </div>
        ) : (
          <>
            <div role="cell" className={`${globalClasses.flexCol2}`}>
              <Typography variant="body2" noWrap>{operation.updated_at.substring(0, 16).replace('T', ' ')}</Typography>
            </div>
            <div className={`${globalClasses.flexCol2}`}>
              <Typography variant="body2" noWrap>{operation.user_name}</Typography>
            </div>
            <div role="cell" className={`${globalClasses.flexCol1}`}>
              <Typography variant="body2" noWrap>{operation.operation_id}</Typography>
            </div>
          </>
        )}
      </div>
    ))
  );

  return (
    <Grid item xs className={classes.root} role="table" aria-label="job operations">
      <Paper elevation={0} className={classes.paper}>
        {title}
        {rows}
      </Paper>
    </Grid>
  );
};

ShowJobOperations.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  operations: array.isRequired,
  removeOperation: func.isRequired,
  jobId: number.isRequired,
  handleCancelJob: func.isRequired,
};

export default ShowJobOperations;
