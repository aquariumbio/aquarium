import Checkbox from '@material-ui/core/Checkbox';
import React, { useState, useEffect } from 'react';
import { func, string } from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Divider from '@material-ui/core/Divider';
import Typography from '@material-ui/core/Typography';
import jobsAPI from '../../helpers/api/jobsAPI';
import VerticalNavList from './VerticalNavList';
import globalUseSyles from '../../globalUseStyles';
import { useWindowDimensions } from '../../WindowDimensionsProvider';
import { StandardButton } from '../shared/Buttons';

const useStyles = makeStyles((theme) => ({
  root: {
    height: 'calc(100% - 64px)',
    display: 'flex',
  },

  inventory: {
    fontSize: '0.875rem',
    marginBottom: theme.spacing(2),
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
}));

// eslint-disable-next-line no-unused-vars
const ShowByOperation = ({
  category,
  operationType,
  setOperationType,
  setPendingCount,
  setAlertProps,
}) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();
  const { tablet } = useWindowDimensions();

  const [operationTypes, setOperationTypes] = useState();
  const [operations, setOperations] = useState();
  const [checked, setChecked] = React.useState([]);

  const init = async () => {
    const response = await jobsAPI.getCategoryByStatus(category);

    if (!response) return;

    const { operation_types: opTypes, ...rest } = response;

    const name = Object.keys(rest)[0];
    setOperationType(name);
    setOperations(rest[name].operations);
    setOperationTypes(opTypes);

    const count = opTypes.reduce((sum, current) => sum + current.n, 0);
    setPendingCount(count);
  };

  useEffect(() => {
    init();
  }, [category]);

  const getOperations = async () => {
    const response = await jobsAPI.getOperationTypeByCategoryAndStatus(operationType, category);
    if (!response) return;
    setOperations(response.operations);
  };

  useEffect(() => {
    getOperations();
  }, [operationType]);

  const handleToggle = (value) => () => {
    const currentIndex = checked.indexOf(value);
    const newChecked = [...checked];

    if (currentIndex === -1) {
      newChecked.push(value);
    } else {
      newChecked.splice(currentIndex, 1);
    }

    setChecked(newChecked);
  };

  const createJob = async () => {
    const response = await jobsAPI.create(checked);
    if (!response) {
      return (
        setAlertProps({
          message: 'Error: could not create job.',
          severity: 'error',
          open: true,
        })
      );
    }

    // If the operation type still has operations keep the current selected operation
    debugger;

    const indexOfCurrent = operations.findIndex((item) => item.name === operationType);
    if (operations[indexOfCurrent].n > checked.length) {
      const updateOperations = operations;
      updateOperations[operationType].n = operations[indexOfCurrent].n - checked.length;
      setOperations(updateOperations);
    } else {
      init();
    }
    setChecked([]);
    return (
      setAlertProps({
        message: `Job #${response.job.id} is waiting for assignment in Unassigned`,
        severity: 'success',
        open: true,
      })
    );
  };

  if (!operationTypes) {
    return <div>{category} has no operations</div>;
  }
  const dispalyData = (operation) => (
    <>
      {!!operation.inputs && operation.inputs.map((input, index) => (
        <div className={`${globalClasses.flex} ${globalClasses.flexRowNested}`}>
          <div className={globalClasses.flexCol1}>
            <Typography noWrap>{index === 0 ? 'in:' : ''}</Typography>
          </div>
          <div className={globalClasses.flexCol2}>
            <Typography noWrap>{input.name}</Typography>
          </div>
          {input.sample_id && input.sample_name ? (
            <div className={globalClasses.flexCol4}>
              <Typography noWrap>{input.sample_id}: {input.sample_name}</Typography>
            </div>
          ) : <div className={globalClasses.flexCol4} />}
        </div>
      ))}

      {!!operation.outputs && operation.outputs.map((output, index) => (
        <div className={`${globalClasses.flex} ${globalClasses.flexRowNested}`}>
          <div className={globalClasses.flexCol1}>
            <Typography>{index === 0 ? 'out:' : ''}</Typography>
          </div>
          <div className={globalClasses.flexCol2}>
            <Typography noWrap>{output.name}</Typography>
          </div>
          {output.sample_id && output.sample_name ? (
            <div className={globalClasses.flexCol4}>
              <Typography noWrap>{output.sample_id}: {output.sample_name}</Typography>
            </div>
          ) : <div className={globalClasses.flexCol4} />}
        </div>
      ))}

      {!!operation.data_associations && operation.data_associations.map((da) => {
        const data = JSON.parse(da.object);
        const key = Object.keys(data)[0];
        const value = data[key];
        // if no associated text skip row
        if (value === '') {
          return false;
        }
        return (
          <div className={`${globalClasses.flex} ${globalClasses.flexRowNested}`}>
            <div className={globalClasses.flexCol1} />
            <div className={globalClasses.flexCol2}>
              <Typography noWrap>{key.replace('_', ' ')}:</Typography>
            </div>
            <div className={globalClasses.flexCol4}>
              <Typography noWrap>{value}</Typography>
            </div>
          </div>
        );
      })}
    </>
  );

  const rows = () => {
    if (!operations) {
      return <div> No operations</div>;
    }

    return (
      operations.map((operation) => (
        <div className={`${globalClasses.flex} ${globalClasses.flexRow} ${checked.includes(operation.id) && globalClasses.hightlight}`} key={`job_${operation.id}`}>
          <div className={`${globalClasses.flexCol1}`}>
            <Checkbox
              color="primary"
              inputProps={{ 'aria-label': 'operation-checkbox' }}
              edge="start"
              checked={checked.indexOf(operation.id) !== -1}
              onChange={handleToggle(operation.id)}
              tabIndex={-1}
              disableRipple
            />
          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography noWrap>{operation.plan_id}</Typography>
          </div>
          <div className={`${globalClasses.flexCol4}`}>
            <Typography noWrap>{dispalyData(operation)}</Typography>
          </div>
          {tablet ? (
            <div className={`${globalClasses.flexCol2}`}>
              <Typography noWrap>Updated: {operation.updated_at.substring(0, 16).replace('T', ' ')}</Typography>
              <Typography noWrap>Researcher: {operation.name}</Typography>
              <Typography noWrap>Op Id: {operation.id}</Typography>
            </div>
          ) : (
            <>
              <div className={`${globalClasses.flexCol2}`}>
                <Typography noWrap>{operation.updated_at.substring(0, 16).replace('T', ' ')}</Typography>
              </div>
              <div className={`${globalClasses.flexCol2}`}>
                <Typography noWrap>{operation.name}</Typography>
              </div>
              <div className={`${globalClasses.flexCol1}`}>
                <Typography noWrap>{operation.id}</Typography>
              </div>
            </>
          )}
        </div>
      ))
    );
  };

  return (
    <div id="show-by-operation" className={classes.root}>
      <VerticalNavList
        name="operation-types"
        list={operationTypes}
        value={operationType}
        setOperationType={setOperationType}
      />
      <div style={{ width: '100%', marginLeft: '20px' }}>
        <Divider style={{ marginTop: '0' }} />
        <StandardButton
          name="create-job"
          text="create job"
          disabled={checked.length < 1}
          icon="attach"
          dense
          variant="text"
          handleClick={createJob}
        />
        <Divider />

        <div>
          <div className={globalClasses.flexWrapper}>
            <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
              <div className={`${globalClasses.flexCol1}`} />
              <div className={`${globalClasses.flexCol1}`}>Plan</div>
              <div className={`${globalClasses.flexCol4}`}>Input/Output</div>
              {tablet ? (
                <div className={`${globalClasses.flexCol2}`}>Details</div>
              ) : (
                <>
                  <div className={`${globalClasses.flexCol2}`}>Updated</div>
                  <div className={`${globalClasses.flexCol2}`}>Researcher</div>
                  <div className={`${globalClasses.flexCol1}`}>Op Id</div>
                </>
              )}
            </div>
            {rows()}
          </div>
        </div>
      </div>
    </div>

  );
};

ShowByOperation.propTypes = {
  category: string.isRequired,
  operationType: string.isRequired,
  setOperationType: func.isRequired,
  setPendingCount: func.isRequired,
  setAlertProps: func.isRequired,

};

export default ShowByOperation;
